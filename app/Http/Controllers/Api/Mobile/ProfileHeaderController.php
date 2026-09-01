<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\AvatarAsset;
use App\Models\ProfileHeaderConfig;
use App\Events\ProfileHeaderUpdated;
use App\Services\SwiftMoji\Renderer;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class ProfileHeaderController extends Controller
{
    public function show(Request $r): JsonResponse
    {
        $user = $r->user();
        $cfg = ProfileHeaderConfig::where('user_id', $user->id)->first();
        return response()->json($cfg ? $cfg->config : null);
    }

    public function update(Request $r, Renderer $renderer): JsonResponse
    {
        $user = $r->user();

        $data = $r->validate([
            'background_id' => ['sometimes','nullable','string','max:255'],
            'pose_id'       => ['sometimes','nullable','string','max:255'],
            'scene_id'      => ['sometimes','nullable','string','max:255'],
            'effects'       => ['sometimes','array'],
            'effects.*'     => ['string','max:255'],
            'avatar_config' => ['sometimes','array'],
            'avatar_position.x' => ['sometimes','numeric','between:0,1'],
            'avatar_position.y' => ['sometimes','numeric','between:0,1'],
            'avatar_scale'       => ['sometimes','numeric','min:0.1','max:5'],
            'avatar_rotation'    => ['sometimes','numeric','min:-360','max:360'],
        ]);

        // Validate referenced asset IDs server-side where applicable
        $idsToCheck = [];
        foreach (['background_id','pose_id','scene_id'] as $k) {
            if (!empty($data[$k])) $idsToCheck[] = $data[$k];
        }
        if (!empty($data['effects']) && is_array($data['effects'])) {
            $idsToCheck = array_merge($idsToCheck, $data['effects']);
        }

        if (!empty($idsToCheck)) {
            $found = AvatarAsset::whereIn('asset_id', $idsToCheck)->where('enabled', true)->pluck('asset_id')->all();
            $missing = array_values(array_diff($idsToCheck, $found));
            if (!empty($missing)) {
                return response()->json(['error' => 'Some asset IDs are invalid or not enabled', 'missing' => $missing], 422);
            }
        }

        $config = array_merge($data, [
            'avatar_position' => $r->input('avatar_position', ['x' => 0.5, 'y' => 0.5]),
            'avatar_scale' => $r->input('avatar_scale', 1.0),
            'avatar_rotation' => $r->input('avatar_rotation', 0),
        ]);

        ksort($config);
        $hash = hash('sha256', json_encode($config));

        $record = ProfileHeaderConfig::updateOrCreate(
            ['user_id' => $user->id],
            ['config' => $config, 'config_hash' => $hash]
        );

        // Attempt to render and cache a preview (best-effort)
        try {
            $renderer->renderHeaderFromConfig($config, $hash);
        } catch (\Throwable $e) {
            // swallow — rendering optional here
        }

        event(new ProfileHeaderUpdated($user->id, $record->config));

        return response()->json($record->config);
    }

    public function reset(Request $r): JsonResponse
    {
        $user = $r->user();
        $record = ProfileHeaderConfig::where('user_id', $user->id)->first();
        if ($record) {
            $record->delete();
        }
        event(new ProfileHeaderUpdated($user->id, null));
        return response()->json(['reset' => true]);
    }
}
