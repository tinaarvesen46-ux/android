<?php

namespace App\Console\Commands;

use App\Models\AvatarAsset;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ImportSwiftMoji extends Command
{
    protected $signature = 'swiftmoji:import {path}';
    protected $description = 'Import a SwiftMoji asset package (zip) or directory into storage/app/avatars_catalog and register assets in DB';

    public function handle(): int
    {
        $inputPath = $this->argument('path');
        if (!file_exists($inputPath)) {
            $this->error('Path not found: ' . $inputPath);
            return 1;
        }

        // Support either a zip file or an already-extracted directory
        if (is_dir($inputPath)) {
            $tmp = rtrim($inputPath, DIRECTORY_SEPARATOR);
        } else {
            $tmp = sys_get_temp_dir() . '/swiftmoji_import_' . time();
            @mkdir($tmp, 0755, true);
            $zip = new \ZipArchive();
            if ($zip->open($inputPath) !== true) {
                $this->error('Unable to open zip');
                return 1;
            }
            $zip->extractTo($tmp);
            $zip->close();
        }

        $catalog = storage_path('app/avatars_catalog');
        @mkdir($catalog, 0755, true);

        $files = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($tmp));
        $count = 0;
        $manifest = [];
        $metadata = ['traits' => [], 'templates' => []];
        foreach ($files as $file) {
            if ($file->isDir()) continue;
            $ext = strtolower($file->getExtension());
            if (!in_array($ext, ['svg','svgf','png','jpg','jpeg'])) continue;

            // compute a category relative to an assets/ folder if present
            $full = $file->getPathname();
            $rel = ltrim(str_replace($tmp, '', $full), DIRECTORY_SEPARATOR);
            $assetsPos = strpos(str_replace('\\','/', $rel), 'assets/');
            if ($assetsPos !== false) {
                $after = substr($rel, $assetsPos + strlen('assets/') );
            } else {
                $after = $rel;
            }
            $parts = explode(DIRECTORY_SEPARATOR, $after);
            // If file sits in a directory under assets, that directory is the category
            if (count($parts) >= 2) {
                $category = $parts[0];
                $name = pathinfo($parts[count($parts)-1], PATHINFO_FILENAME);
            } else {
                // single file directly under assets (e.g., shared_defs.svgf, body.svgf)
                $baseName = pathinfo($parts[0], PATHINFO_FILENAME);
                // Use the filename as category for root-level svgf files, otherwise put in 'misc'
                $category = in_array($ext, ['svgf','svg']) ? $baseName : 'misc';
                $name = $baseName;
            }

            $destDir = "{$catalog}/{$category}";
            @mkdir($destDir, 0755, true);
            $dest = "{$destDir}/{$name}.{$ext}";
            // avoid copying over existing files unless different
            if (!file_exists($dest) || filesize($full) !== filesize($dest)) {
                copy($full, $dest);
            }

            // Create DB row only for actual files we copied into catalog
            AvatarAsset::updateOrCreate(['asset_id' => $name], [
                'category' => $category,
                'filename' => "{$category}/{$name}.{$ext}",
                'mime' => ($ext === 'svgf') ? 'image/svg+xml' : (mime_content_type($dest) ?: null),
                'meta' => json_encode(['imported_at' => now()->toDateTimeString()]),
                'enabled' => true,
            ]);
            // Add to manifest structure
            $manifest[$category] = $manifest[$category] ?? [];
            $manifest[$category][] = [
                'asset_id' => $name,
                'filename' => "{$category}/{$name}.{$ext}",
                'mime' => ($ext === 'svgf') ? 'image/svg+xml' : (mime_content_type($dest) ?: null),
                'enabled' => true,
                'available' => true,
            ];

            // Create thumbnail entry (copy original into thumbnails folder)
            // Create thumbnail entry: prefer an existing PNG with same basename in source
            $thumbDir = storage_path("app/avatars_catalog/thumbnails/{$category}");
            @mkdir($thumbDir, 0755, true);
            $thumbDestPng = "{$thumbDir}/{$name}.png";
            if ($ext === 'png') {
                if (!file_exists($thumbDestPng)) copy($full, $thumbDestPng);
            } else {
                // look for a png sibling in the same source folder
                $pngSibling = dirname($full) . DIRECTORY_SEPARATOR . $name . '.png';
                if (file_exists($pngSibling)) {
                    if (!file_exists($thumbDestPng)) copy($pngSibling, $thumbDestPng);
                }
            }

            $count++;
        }

        // look for metadata JSON files in the extracted package and merge into manifest
        $metaFiles = [
            'bitmoji_avatar_builder_assets.json',
            'bitmoji_content_templates.json',
        ];
        foreach ($metaFiles as $mf) {
            $path = $tmp . DIRECTORY_SEPARATOR . $mf;
            if (file_exists($path)) {
                $raw = file_get_contents($path);
                $json = json_decode($raw, true);
                if ($json) {
                    if (strpos($mf, 'avatar_builder') !== false && isset($json['traits'])) {
                        $metadata['traits'] = array_merge($metadata['traits'], $json['traits']);
                    }
                    if (strpos($mf, 'content_templates') !== false && isset($json['imoji'])) {
                        $metadata['templates'] = array_merge($metadata['templates'], $json['imoji']);
                    }
                }
            }
        }

        // Merge metadata into manifest (metadata only, do not create DB rows for external assets)
        $catalogRoot = storage_path('app/avatars_catalog');
        $fullManifest = ['generated_at' => now()->toDateTimeString(), 'categories' => $manifest, 'metadata' => $metadata];
        $manifestPath = "{$catalogRoot}/manifest.json";
        file_put_contents($manifestPath, json_encode($fullManifest, JSON_PRETTY_PRINT));

        $this->info("Imported {$count} assets");
        $this->info("Manifest written to: {$manifestPath}");
        return 0;
    }
}
