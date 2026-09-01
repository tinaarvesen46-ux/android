<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\PublicProfile;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PublicProfileController extends Controller
{
    public function show(Request $r, string $username): JsonResponse
    {
        $p = PublicProfile::where('username', $username)->where('is_enabled', true)->firstOrFail();
        return response()->json($p->load('user.profile'));
    }

    public function store(Request $r): JsonResponse
    {
        $data = $r->validate([
            'display_name' => ['required','string','max:100'],
            'username'     => ['required','string','max:30'],
            'bio'          => ['sometimes','nullable','string','max:500'],
            'is_enabled'   => ['sometimes','boolean'],
        ]);
        $data['user_id'] = $r->user()->id;
        $p = PublicProfile::create($data);
        return response()->json($p, 201);
    }

    public function update(Request $r): JsonResponse
    {
        $u = $r->user();
        $data = $r->validate([
            'display_name' => ['sometimes','string','max:100'],
            'username'     => ['sometimes','string','max:30'],
            'bio'          => ['sometimes','nullable','string','max:500'],
            'is_enabled'   => ['sometimes','boolean'],
        ]);
        $p = PublicProfile::updateOrCreate(['user_id' => $u->id], $data);
        return response()->json($p);
    }

    public function destroy(Request $r): JsonResponse
    {
        $p = PublicProfile::where('user_id', $r->user()->id)->first();
        if ($p) $p->delete();
        return response()->json(['deleted' => true]);
    }
}
