<?php

namespace App\Services\SwiftMoji;

use Illuminate\Support\Str;

class Renderer
{
    protected array $layerOrder = [
        // SwiftMoji's imported avatar_builder package uses these categories.
        'body', 'eyes', 'eyebrows', 'nose', 'mouths', 'facial_hair',
        'clothing', 'graphic_clothing', 'top', 'accessories', 'avatar_builder',
        // Keep compatibility with older configurations.
        'background', 'base', 'skin', 'face_lines', 'cheek_details',
        'eye_details', 'mouth', 'facialHair', 'hair', 'hair_color', 'glasses',
        'hat', 'top_color', 'bottom', 'bottom_color', 'shoes',
    ];

    public function renderSvgFromConfig(array $config): string
    {
        $catalogPath = storage_path('app/avatars_catalog');
        $svgParts = [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="256" height="256" viewBox="0 0 256 256">',
            '<rect width="100%" height="100%" fill="#ffffff" />',
        ];
        // include shared defs if present (svgf or svg)
        $sharedDefs = null;
        foreach (['svgf','svg'] as $sExt) {
            $sharedPath = file_exists("{$catalogPath}/shared_defs.{$sExt}")
                ? "{$catalogPath}/shared_defs.{$sExt}"
                : "{$catalogPath}/shared_defs/shared_defs.{$sExt}";
            if (file_exists($sharedPath)) {
                $sharedDefs = file_get_contents($sharedPath);
                break;
            }
        }
        if ($sharedDefs) {
            $sharedInner = $this->inlineSvgFragment($sharedDefs);
            $svgParts[] = $sharedInner;
        }

        foreach ($this->layerOrder as $layer) {
            if (!isset($config[$layer])) continue;
            $id = $config[$layer];
            // try svgf first, then svg, then raster
            $found = false;
            foreach (['svgf','svg','png','jpg','jpeg'] as $ext) {
                $path = $this->assetPath($catalogPath, $layer, $id, $ext);
                if (file_exists($path)) {
                    $data = file_get_contents($path);
                    $mime = $this->mimeForExt($ext);
                    if (in_array($ext, ['svgf','svg'])) {
                        // inline fragment or svg: strip XML prolog if present
                        $inner = $this->inlineSvgFragment($data);
                        $svgParts[] = $inner;
                    } else {
                        $b64 = base64_encode($data);
                        $svgParts[] = sprintf('<image href="data:%s;base64,%s" x="0" y="0" width="256" height="256" preserveAspectRatio="xMidYMid meet" />', $mime, $b64);
                    }
                    $found = true;
                    break;
                }
            }
            if (!$found) {
                // missing layer: continue silently
                continue;
            }
        }

        $svgParts[] = '</svg>';
        return implode("\n", $svgParts);
    }

    public function hashConfig(array $config): string
    {
        ksort($config);
        return Str::slug(hash('sha256', json_encode($config)), '-') ;
    }

    public function renderHeaderFromConfig(array $headerConfig, ?string $hash = null): string
    {
        // headerConfig may contain 'avatar_config' and presentation keys
        $avatarConfig = is_array($headerConfig['avatar_config'] ?? null)
            ? $headerConfig['avatar_config']
            : [];
        $bgId = $headerConfig['background_id'] ?? ($headerConfig['scene_id'] ?? null);

        $combined = $this->renderSvgFromConfig($avatarConfig);

        // Compose a stable 1024x384 header even when no scene asset exists.
        $out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            . "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"1024\" height=\"384\" viewBox=\"0 0 1024 384\">\n"
            . '<defs><linearGradient id="swiftmoji-header-gradient" x1="0" y1="0" x2="1" y2="1">'
            . '<stop offset="0" stop-color="#6655d9"/><stop offset="1" stop-color="#a45be8"/></linearGradient></defs>'
            . "<rect width=\"1024\" height=\"384\" fill=\"url(#swiftmoji-header-gradient)\"/>\n";

        // If a background is specified and exists, overlay it behind the avatar.
        if ($bgId) {
            $catalogPath = storage_path('app/avatars_catalog');
            foreach (['svgf','svg','png','jpg','jpeg'] as $ext) {
                $path = $this->assetPath($catalogPath, 'background', $bgId, $ext);
                if (file_exists($path)) {
                    $bgData = file_get_contents($path);
                    if (in_array($ext, ['svgf', 'svg'])) {
                        $out .= $this->inlineSvgFragment($bgData);
                    } else {
                        $b64 = base64_encode($bgData);
                        $out .= sprintf('<image href="data:%s;base64,%s" x="0" y="0" width="1024" height="384" preserveAspectRatio="xMidYMid slice" />', $this->mimeForExt($ext), $b64);
                    }
                    break;
                }
            }
        }

        $position = is_array($headerConfig['avatar_position'] ?? null)
            ? $headerConfig['avatar_position'] : [];
        $x = max(0, min(1, (float) ($position['x'] ?? 0.5))) * 1024;
        $y = max(0, min(1, (float) ($position['y'] ?? 0.5))) * 384;
        $scale = max(0.1, min(5, (float) ($headerConfig['avatar_scale'] ?? 1.0)));
        $rotation = max(-360, min(360, (float) ($headerConfig['avatar_rotation'] ?? 0)));
        $out .= sprintf('<g transform="translate(%.2f %.2f) rotate(%.2f) scale(%.4f) translate(-128 -128)">', $x, $y, $rotation, $scale);
        $out .= $this->inlineSvgFragment($combined);
        $out .= "</g>\n</svg>";
        $hash = $hash ?? hash('sha256', $out);
        $cacheDir = storage_path('app/avatars_cache');
        @mkdir($cacheDir, 0755, true);
        @file_put_contents($cacheDir . '/profile_header_' . $hash . '.svg', $out);
        return $out;
    }

    protected function assetPath(string $catalogPath, string $layer, string $id, string $ext): string
    {
        $safeLayer = trim($layer, '/\\');
        $safeId = basename($id);
        $aliases = [
            'facialHair' => 'facial_hair',
            'mouth' => 'mouths',
        ];
        $dir = $aliases[$safeLayer] ?? $safeLayer;
        $path = "{$catalogPath}/{$dir}/{$safeId}.{$ext}";
        if (file_exists($path)) return $path;
        return "{$catalogPath}/{$safeLayer}/{$safeId}.{$ext}";
    }

    protected function inlineSvgFragment(string $data): string
    {
        $data = preg_replace('/^\s*<\?xml.*?\?>/s', '', $data) ?? $data;
        return preg_replace('/<\/?svg\b[^>]*>/i', '', $data) ?? $data;
    }

    protected function mimeForExt(string $ext): string
    {
        return match ($ext) {
            'png' => 'image/png', 'jpg', 'jpeg' => 'image/jpeg', 'svg', 'svgf' => 'image/svg+xml', default => 'application/octet-stream'
        };
    }
}
