<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class FetchSwiftMojiAssets extends Command
{
    protected $signature = 'swiftmoji:fetch {--no-libmoji : Do not attempt fetching from the libmoji repository}';
    protected $description = 'Fetch and cache SwiftMoji avatar assets from public sources into storage/avatars_catalog';

    public function handle(): int
    {
        $this->info('Starting SwiftMoji asset fetch...');

        $base = storage_path('app/avatars_catalog');
        if (!is_dir($base)) mkdir($base, 0755, true);

        // Categories consistent with AvatarController::catalog()
        $cats = ['skin','face','hair','hair_color','eyebrows','eyes','eye_color','nose','mouth','facialHair','glasses','hat','top','top_color','bottom','bottom_color','shoes','accessories','background'];
        foreach ($cats as $c) {
            if (!is_dir("{$base}/{$c}")) mkdir("{$base}/{$c}", 0755, true);
        }

        // Try Bitmoji asset endpoints
        $sources = [
            'https://api.bitmoji.com/avatar-builder-v3/assets',
            'https://api.bitmoji.com/content/templates',
        ];

        $manifest = [];

        foreach ($sources as $url) {
            $this->info("Fetching manifest: {$url}");
            $json = @file_get_contents($url);
            if (!$json) {
                $this->warn("Could not fetch {$url}");
                continue;
            }
            $data = json_decode($json, true);
            if (!$data) {
                $this->warn("Invalid JSON from {$url}");
                continue;
            }
            $manifest = array_merge($manifest, $data);
        }

        // If manifest entries are objects with asset URLs, attempt to download.
        $downloaded = 0;
        foreach ($manifest as $entry) {
            if (!is_array($entry)) continue;
            // try keys that look like id/url
            $id = $entry['id'] ?? ($entry['name'] ?? null);
            $src = $entry['url'] ?? $entry['src'] ?? $entry['image'] ?? null;
            $cat = $entry['category'] ?? null;
            if (!$id || !$src) continue;
            if ($cat && in_array($cat, $cats, true)) {
                $ext = pathinfo(parse_url($src, PHP_URL_PATH), PATHINFO_EXTENSION) ?: 'svg';
                $dest = "{$base}/{$cat}/{$id}.{$ext}";
                if (file_exists($dest)) { $this->line("exists: {$dest}"); continue; }
                $this->line("Downloading {$src} -> {$dest}");
                $cont = @file_get_contents($src);
                if ($cont) {
                    file_put_contents($dest, $cont);
                    $downloaded++;
                }
            }
        }

        // Optionally attempt libmoji if nothing found
        if ($downloaded === 0 && ! $this->option('no-libmoji')) {
            $this->info('Attempting to fetch libmoji repository as fallback...');
            $zipUrl = 'https://github.com/matthewnau/libmoji/archive/refs/heads/master.zip';
            $tmp = sys_get_temp_dir() . '/libmoji_master.zip';
            $this->line("Downloading {$zipUrl}");
            $z = @file_get_contents($zipUrl);
            if ($z) {
                file_put_contents($tmp, $z);
                $this->line('Extracting...');
                $zip = new \ZipArchive();
                if ($zip->open($tmp) === true) {
                    $extractTo = sys_get_temp_dir() . '/libmoji_master';
                    if (!is_dir($extractTo)) mkdir($extractTo, 0755, true);
                    $zip->extractTo($extractTo);
                    $zip->close();
                    // attempt to copy any svg/png assets into catalog
                    $iterator = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($extractTo));
                    foreach ($iterator as $file) {
                        if ($file->isDir()) continue;
                        $ext = strtolower($file->getExtension());
                        if (!in_array($ext, ['svg','png','jpg','jpeg'])) continue;
                        $name = $file->getBasename('.' . $ext);
                        // naive mapping: try find category in filename
                        foreach ($cats as $cat) {
                            if (stripos($name, $cat) !== false) {
                                $dest = "{$base}/{$cat}/{$name}.{$ext}";
                                if (!file_exists($dest)) copy($file->getPathname(), $dest);
                                $downloaded++;
                                break;
                            }
                        }
                    }
                }
                @unlink($tmp);
            }
        }

        file_put_contents("{$base}/manifest.json", json_encode(['downloaded' => $downloaded, 'timestamp' => time()], JSON_PRETTY_PRINT));
        $this->info("Finished. Downloaded: {$downloaded}");
        return 0;
    }
}
