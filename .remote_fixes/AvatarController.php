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
use Illuminate\Support\Facades\Storage;

/**
 * AvatarController — SwiftSnap avatar (Bitmoji-style) config.
 * Stored as validated component IDs (JSON) on user_profiles.avatar_config.
 * All IDs are validated server-side against the SwiftSnap-owned catalog;
 * arbitrary paths/URLs are rejected.
 */
class AvatarController extends Controller
{
    /** SwiftSnap-owned avatar component catalog (data-driven, id ranges). */
    public static function catalog(): array
    {
        // If DB catalog exists, load categories dynamically
        $cats = AvatarAsset::where('enabled', true)->select('category')->distinct()->pluck('category')->toArray();
        if (!empty($cats)) {
            $out = [];
            foreach ($cats as $c) {
                $out[$c] = AvatarAsset::where('category', $c)->where('enabled', true)->pluck('asset_id')->toArray();
            }
            return $out;
        }

        // Fallback static ranges for local development
        $range = fn (string $p, int $a, int $b) => array_map(
            fn ($i) => sprintf('%s_%02d', $p, $i), range($a, $b)
        );
        return [
            'skin'       => $range('skin', 1, 8),
            'face'       => $range('face', 1, 5),
            'hair'       => array_merge(['hair_00'], $range('hair', 1, 20)),
            'hair_color' => $range('haircol', 1, 12),
            'eyebrows'   => $range('brow', 1, 8),
            'eyes'       => $range('eyes', 1, 10),
            'eye_color'  => $range('eyecol', 1, 8),
            'nose'       => $range('nose', 1, 6),
            'mouth'      => $range('mouth', 1, 8),
            'facialHair' => array_merge(['beard_00'], $range('beard', 1, 10)),
            'glasses'    => array_merge(['glasses_00'], $range('glasses', 1, 8)),
            'hat'        => array_merge(['hat_00'], $range('hat', 1, 10)),
            'top'        => $range('top', 1, 15),
            'top_color'  => $range('topcol', 1, 12),
            'bottom'     => $range('bottom', 1, 10),
            'bottom_color' => $range('botcol', 1, 10),
            'shoes'      => $range('shoes', 1, 10),
            'accessories'=> array_merge(['acc_00'], $range('acc', 1, 8)),
            'background' => $range('bg', 1, 10),
        ];
    }

    public static function defaultConfig(): array
    {
        return [
            'skin' => 'skin_03', 'face' => 'face_01', 'hair' => 'hair_02',
            'hair_color' => 'haircol_01', 'eyebrows' => 'brow_01', 'eyes' => 'eyes_01',
            'eye_color' => 'eyecol_01', 'nose' => 'nose_01', 'mouth' => 'mouth_01',
            'facialHair' => 'beard_00', 'glasses' => 'glasses_00', 'hat' => 'hat_00',
            'top' => 'top_01', 'top_color' => 'topcol_01', 'bottom' => 'bottom_01',
            'bottom_color' => 'botcol_01', 'shoes' => 'shoes_01', 'accessories' => 'acc_00',
            'background' => 'bg_01',
        ];
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

    /** GET /api/v1/avatar — current config (or null) + full catalog + default. */
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

    /** GET /api/v1/avatar/render/{id} — simple deterministic SVG renderer */
    public function render(Request $r, string $id)
    {
        $p = DB::table('user_profiles')->where('user_id', $id)->first();
        $config = $p && $p->avatar_config ? json_decode($p->avatar_config, true) : self::defaultConfig();

        $renderer = new Renderer();
        $hash = $renderer->hashConfig($config);
        $cacheKey = 'swiftmoji:render:' . $hash;

        if (Cache::has($cacheKey)) {
            $cachedPath = Cache::get($cacheKey);
            if ($cachedPath && Storage::exists($cachedPath)) {
                $svg = Storage::get($cachedPath);
                return response($svg, 200)->header('Content-Type', 'image/svg+xml');
            }
        }

        $svg = $renderer->renderSvgFromConfig($config);
        $storePath = "avatars_cache/{$hash}.svg";
        Storage::put($storePath, $svg);
        Cache::put($cacheKey, $storePath, 60 * 60 * 24 * 7);
        return response($svg, 200)->header('Content-Type', 'image/svg+xml');
    }

    /** PUT /api/v1/avatar — validate every component against the catalog + save. */
    public function update(Request $r): JsonResponse
    {
        $data = $r->validate(['config' => ['required', 'array']]);
        $clean = [];
        foreach ($data['config'] as $cat => $id) {
            if (!is_string($id)) {
                return response()->json(['message' => "Invalid component for {$cat}"], 422);
            }
            $exists = AvatarAsset::where('category', $cat)->where('asset_id', $id)->where('enabled', true)->exists();
            if (!$exists) {
                return response()->json(['message' => "Invalid or unknown asset '{$id}' for {$cat}"], 422);
            }
            $clean[$cat] = $id;
        }
        DB::table('user_profiles')->where('user_id', $r->user()->id)->update([
            'avatar_config' => json_encode($clean), 'updated_at' => now(),
        ]);
        $p = DB::table('user_profiles')->where('user_id', $r->user()->id)->first();
        $avatarUrl = $p->avatar_url ?? null;
        event(new AvatarUpdated($r->user()->id, $clean, $avatarUrl));
        return response()->json(['saved' => true, 'config' => $clean]);
    }

    /** POST /api/v1/avatar/reset — restore the system default config. */
    public function reset(Request $r): JsonResponse
    {
        $this->profile($r->user()->id);
        $def = self::defaultConfig();
        DB::table('user_profiles')->where('user_id', $r->user()->id)->update([
            'avatar_config' => json_encode($def), 'updated_at' => now(),
        ]);
        $p = DB::table('user_profiles')->where('user_id', $r->user()->id)->first();
        $avatarUrl = $p->avatar_url ?? null;
        event(new AvatarUpdated($r->user()->id, $def, $avatarUrl));
        return response()->json(['reset' => true, 'config' => $def]);
    }
}
