<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Services\AiConversationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class MyAiController extends Controller
{
    public function index(Request $request, AiConversationService $conversations): JsonResponse
    {
        try {
            return response()->json($conversations->history($request->user()->id));
        } catch (Throwable $e) {
            report($e);
            return response()->json(['message' => 'My AI is unavailable right now.', 'code' => 'ai_unavailable'], 503);
        }
    }

    public function message(Request $request, AiConversationService $conversations): JsonResponse
    {
        $data = $request->validate(['prompt' => ['required', 'string', 'min:1', 'max:4000']]);
        try {
            return response()->json(['reply' => $conversations->send($request->user()->id, $data['prompt'])]);
        } catch (Throwable $e) {
            report($e);
            return response()->json([
                'message' => $e->getMessage() ?: 'My AI is unavailable right now.',
                'code' => 'ai_unavailable',
            ], 503);
        }
    }
}
