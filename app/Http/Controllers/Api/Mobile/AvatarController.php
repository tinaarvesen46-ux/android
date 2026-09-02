<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Events\AvatarUpdated;
use App\Models\AvatarAsset;
use App\Services\SwiftMoji\Renderer;
use Illuminate\Support\Facades\Cache;

class AvatarController extends Controller
{
    public static function catalog(): array
    {
        $cats = AvatarAsset::where('enabled', true)->select('category')->distinct()->pluck('category')->toArray();
        $out = [];
        if (!empty($cats)) {
            foreach ($cats as $c) {
                $items = AvatarAsset::where('category', $c)->where('enabled', true)->get();
                $out[$c] = $items->map(function ($a) {
                    return ['asset_id' => $a->asset_id, 'available' => true];
                })->toArray();
            }
        }

        // If there are no DB assets for some categories, attempt to read manifest metadata
        $manifestPath = storage_path('app/avatars_catalog/manifest.json');
        if (file_exists($manifestPath)) {
            $raw = json_decode(file_get_contents($manifestPath), true);
            $catsMeta = $raw['categories'] ?? [];
            foreach ($catsMeta as $cat => $items) {
                if (!isset($out[$cat])) {
                    $out[$cat] = [];
                    foreach ($items as $it) {
                        $out[$cat][] = ['asset_id' => $it['asset_id'] ?? ($it['id'] ?? null), 'available' => false];
                    }
                }
            }
        }

        return $out;
    }

    public static function defaultConfig(): array
    {
        $legacy = [
            'skin' => 'skin_03', 'face' => 'face_01', 'hair' => 'hair_02',
            'hair_color' => 'haircol_01', 'eyebrows' => 'brow_01', 'eyes' => 'eyes_01',
            'eye_color' => 'eyecol_01', 'nose' => 'nose_01', 'mouth' => 'mouth_01',
            'facialHair' => 'beard_00', 'glasses' => 'glasses_00', 'hat' => 'hat_00',
            'top' => 'top_01', 'top_color' => 'topcol_01', 'bottom' => 'bottom_01',
            'bottom_color' => 'botcol_01', 'shoes' => 'shoes_01', 'accessories' => 'acc_00',
            'background' => 'bg_01',
        ];

        // Prefer the first real imported asset for each composable category.
        // This keeps a new installation renderable without inventing IDs.
        try {
            $config = [];
            foreach (['body', 'eyes', 'eyebrows', 'nose', 'mouths', 'facial_hair', 'clothing', 'top', 'accessories'] as $category) {
                $asset = AvatarAsset::where('category', $category)
                    ->where('enabled', true)->orderBy('asset_id')->first();
                if ($asset) $config[$category] = $asset->asset_id;
            }
            return $config ?: $legacy;
        } catch (\Throwable $e) {
            return $legacy;
        }
    }

    private function profile(int $uid)
    {
        $p = DB::table('user_profiles')->where('user_id', $uid)->first();
        if (!$p) {
            DB::table('user_profiles')->insert([
                'user_id' => $uid, 'created_at' => now(), 'updated_at' => now(),
            ]);
            $p = DB::table('user_profiles')->where('user_id', $uid)->first();
        }
        return $p;
    }

    public function show(Request $r): JsonResponse
    {
        $p = $this->profile($r->user()->id);
        $config = $p->avatar_config ? json_decode($p->avatar_config, true) : null;
        return response()->json([
            'has_avatar' => $config !== null,
            'config'     => $config,
            'default'    => self::defaultConfig(),
            'catalog'    => self::catalog(),
            'avatar_url' => $p->avatar_url,
            'render_url' => url('/api/v1/avatar/render/' . $r->user()->id),
        ]);
    }

    public function render(Request $r, string $id)
    {
        $p = DB::table('user_profiles')->where('user_id', $id)->first();
        $saved = $p && $p->avatar_config ? json_decode($p->avatar_config, true) : [];
        $config = array_merge(self::defaultConfig(), is_array($saved) ? $saved : []);

        $renderer = new Renderer();
        $hash = $renderer->hashConfig($config);
        $cacheKey = 'swiftmoji:render:' . $hash;

        if (Cache::has($cacheKey)) {
            $cachedPath = Cache::get($cacheKey);
            if ($cachedPath && is_file($cachedPath)) {
                $svg = file_get_contents($cachedPath);
                return response($svg, 200)->header('Content-Type', 'image/svg+xml');
            }
        }

        $svg = $renderer->renderSvgFromConfig($config);
        $cacheDir = storage_path('app/avatars_cache');
        @mkdir($cacheDir, 0755, true);
        $storePath = $cacheDir . "/{$hash}.svg";
        file_put_contents($storePath, $svg);
        Cache::put($cacheKey, $storePath, now()->addDays(7));
        return response($svg, 200)->header('Content-Type', 'image/svg+xml');
    }

    public function renderHeader(Request $r, string $id)
    {
        // look up profile header config
        $cfg = \App\Models\ProfileHeaderConfig::where('user_id', $id)->first();
        $config = $cfg && $cfg->config ? $cfg->config : [];
        $profile = DB::table('user_profiles')->where('user_id', $id)->first();
        $savedAvatar = $profile && $profile->avatar_config ? json_decode($profile->avatar_config, true) : [];
        // The current profile avatar is the source of truth. Header layout,
        // scene and effects remain stored in the header record, but an old
        // embedded avatar_config must never mask a newly saved avatar.
        if (is_array($savedAvatar) && !empty($savedAvatar)) {
            $config['avatar_config'] = array_merge(self::defaultConfig(), $savedAvatar);
        } elseif (!isset($config['avatar_config']) || !is_array($config['avatar_config'])) {
            $config['avatar_config'] = self::defaultConfig();
        }

        $renderer = new Renderer();
        $hash = $renderer->hashConfig($config ?? []);
        $cacheKey = 'swiftmoji:profile_header_render:' . $hash;

        if (\Cache::has($cacheKey)) {
            $cachedPath = \Cache::get($cacheKey);
            if ($cachedPath && is_file($cachedPath)) {
                $svg = file_get_contents($cachedPath);
                return response($svg, 200)->header('Content-Type', 'image/svg+xml');
            }
        }

        $svg = $renderer->renderHeaderFromConfig($config ?? [] , $hash);
        $cacheDir = storage_path('app/avatars_cache');
        @mkdir($cacheDir, 0755, true);
        $storePath = $cacheDir . "/profile_header_{$hash}.svg";
        file_put_contents($storePath, $svg);
        \Cache::put($cacheKey, $storePath, now()->addDays(7));
        return response($svg, 200)->header('Content-Type', 'image/svg+xml');
    }

    public function catalogList(Request $r): JsonResponse
    {
        $q = $r->query('q');
        $category = $r->query('category');
        $page = max(1, (int) $r->query('page', 1));
        $perPage = min(100, max(10, (int) $r->query('per_page', 40)));

        $query = AvatarAsset::where('enabled', true);
        if ($category) $query->where('category', $category);
        if ($q) $query->where('asset_id', 'like', "%{$q}%");

        $total = $query->count();
        $items = $query->orderBy('category')->orderBy('asset_id')->skip(($page - 1) * $perPage)->take($perPage)->get();

        $data = $items->map(function ($a) {
            return [
                'asset_id' => $a->asset_id,
                'category' => $a->category,
                'thumbnail_url' => url("/api/v1/avatar/asset/{$a->category}/{$a->asset_id}/thumb"),
                'filename' => $a->filename,
                'available' => true,
            ];
        })->toArray();

        // If DB returned no items for this category, fall back to manifest metadata
        if (empty($data) && $category) {
            $manifestPath = storage_path('app/avatars_catalog/manifest.json');
            if (file_exists($manifestPath)) {
                $raw = json_decode(file_get_contents($manifestPath), true);
                $catsMeta = $raw['categories'] ?? [];
                if (isset($catsMeta[$category])) {
                    $metaItems = $catsMeta[$category];
                    $data = array_map(function ($it) use ($category) {
                        return [
                            'asset_id' => $it['asset_id'] ?? ($it['id'] ?? null),
                            'category' => $category,
                            'thumbnail_url' => null,
                            'filename' => $it['filename'] ?? null,
                            'available' => false,
                        ];
                    }, $metaItems);
                }
            }
        }

        return response()->json(['total' => $total, 'page' => $page, 'per_page' => $perPage, 'items' => $data]);
    }

    public function assetThumbnail(Request $r, string $category, string $id)
    {
        $asset = AvatarAsset::where('category', $category)->where('asset_id', $id)->first();
        if (!$asset) return response()->json(['message' => 'Not found'], 404);
        $thumbPath = storage_path("app/avatars_catalog/thumbnails/{$category}/{$id}.png");
        $origPath = storage_path('app/avatars_catalog/' . $asset->filename);

        // If thumbnail exists, serve it
        if (is_file($thumbPath)) {
            return response()->file($thumbPath, ['Content-Type' => 'image/png']);
        }

        // If original exists, attempt to generate a thumbnail (best-effort)
        if (is_file($origPath)) {
            $fullOrig = $origPath;
            $tmpOut = sys_get_temp_dir() . DIRECTORY_SEPARATOR . "thumb_{$category}_{$id}.png";

            // Try rsvg-convert then imagemagick convert as fallbacks
            $rsvg = trim(shell_exec('which rsvg-convert 2>/dev/null'));
            $convert = trim(shell_exec('which convert 2>/dev/null'));
            $ok = false;
            if ($rsvg) {
                $cmd = escapeshellcmd($rsvg) . ' -w 256 -h 256 -o ' . escapeshellarg($tmpOut) . ' ' . escapeshellarg($fullOrig) . ' 2>/dev/null';
                @shell_exec($cmd);
                if (file_exists($tmpOut)) {
                    @mkdir(dirname($thumbPath), 0755, true);
                    file_put_contents($thumbPath, file_get_contents($tmpOut));
                    @unlink($tmpOut);
                    return response()->file($thumbPath, ['Content-Type' => 'image/png']);
                }
            }
            if ($convert) {
                $cmd = escapeshellcmd($convert) . ' -background none -resize 256x256 ' . escapeshellarg($fullOrig) . ' ' . escapeshellarg($tmpOut) . ' 2>/dev/null';
                @shell_exec($cmd);
                if (file_exists($tmpOut)) {
                    @mkdir(dirname($thumbPath), 0755, true);
                    file_put_contents($thumbPath, file_get_contents($tmpOut));
                    @unlink($tmpOut);
                    return response()->file($thumbPath, ['Content-Type' => 'image/png']);
                }
            }

            // Fallback: serve original
            return response()->file($origPath, ['Content-Type' => $asset->mime ?: 'image/svg+xml']);
        }

        return response()->json(['message' => 'Asset file missing'], 410);
    }

    public function update(Request $r): JsonResponse
    {
        $data = $r->validate(['config' => ['required', 'array']]);
        $clean = [];

        $p = DB::table('user_profiles')->where('user_id', $r->user()->id)->first();
        $oldConfig = $p && $p->avatar_config ? json_decode($p->avatar_config, true) : null;

        foreach ($data['config'] as $cat => $id) {
            if (!is_string($id)) {
                return response()->json(['message' => "Invalid component for {$cat}"], 422);
            }
            $asset = AvatarAsset::where('category', $cat)->where('asset_id', $id)->where('enabled', true)->first();
            if (!$asset) {
                return response()->json(['message' => "Invalid or unknown asset '{$id}' for {$cat}"], 422);
            }
            // Ensure file exists in catalog
            $filePath = storage_path('app/avatars_catalog/' . $asset->filename);
            if (!file_exists($filePath)) {
                return response()->json(['message' => "Asset file missing for '{$id}' in {$cat}"], 422);
            }
            $clean[$cat] = $id;
        }

        DB::table('user_profiles')->where('user_id', $r->user()->id)->update([
            'avatar_config' => json_encode($clean), 'updated_at' => now(),
        ]);

        // Invalidate cached render for previous config
        $renderer = new Renderer();
        if (is_array($oldConfig)) {
            $oldHash = $renderer->hashConfig(array_merge(self::defaultConfig(), $oldConfig));
            $oldKey = 'swiftmoji:render:' . $oldHash;
            if (Cache::has($oldKey)) {
                $oldPath = Cache::get($oldKey);
                Cache::forget($oldKey);
                if ($oldPath && is_file($oldPath)) {
                    @unlink($oldPath);
                }
            }
        }

        $p = DB::table('user_profiles')->where('user_id', $r->user()->id)->first();
        $avatarUrl = $p->avatar_url ?? null;
        event(new AvatarUpdated($r->user()->id, $clean, $avatarUrl));
        return response()->json(['saved' => true, 'config' => $clean]);
    }

    public function reset(Request $r): JsonResponse
    {
        $this->profile($r->user()->id);
        $def = self::defaultConfig();
        // Invalidate previous cache similar to update
        $p = DB::table('user_profiles')->where('user_id', $r->user()->id)->first();
        $oldConfig = $p && $p->avatar_config ? json_decode($p->avatar_config, true) : null;
        $renderer = new Renderer();
        if (is_array($oldConfig)) {
            $oldHash = $renderer->hashConfig(array_merge(self::defaultConfig(), $oldConfig));
            $oldKey = 'swiftmoji:render:' . $oldHash;
            if (Cache::has($oldKey)) {
                $oldPath = Cache::get($oldKey);
                Cache::forget($oldKey);
                if ($oldPath && is_file($oldPath)) {
                    @unlink($oldPath);
                }
            }
        }

        DB::table('user_profiles')->where('user_id', $r->user()->id)->update([
            'avatar_config' => json_encode($def), 'updated_at' => now(),
        ]);

        $avatarUrl = $p->avatar_url ?? null;
        event(new AvatarUpdated($r->user()->id, $def, $avatarUrl));
        return response()->json(['reset' => true, 'config' => $def]);
    }
}
