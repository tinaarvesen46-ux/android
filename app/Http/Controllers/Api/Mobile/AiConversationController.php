<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Models\User;
use App\Services\AiConversationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Adds the real My AI conversation to the existing conversation index. */
class AiConversationController extends ConversationController
{
    public function index(Request $request): JsonResponse
    {
        $ai = app(AiConversationService::class);
        $conversation = $ai->conversationFor($request->user()->id);
        $response = parent::index($request);
        $items = json_decode($response->getContent(), true) ?: [];
        $found = false;
        foreach ($items as &$item) {
            if ((string) ($item['id'] ?? '') !== (string) $conversation->id) continue;
            $item['type'] = 'ai';
            $item['is_group'] = false;
            $item['is_pinned'] = true;
            $item['participant'] = $this->aiParticipant($ai);
            $found = true;
            break;
        }
        unset($item);
        if (! $found) {
            $items[] = [
                'id' => (string) $conversation->id,
                'participant' => $this->aiParticipant($ai),
                'last_message' => null,
                'unread_count' => 0,
                'is_pinned' => true,
                'is_muted' => false,
                'is_typing' => false,
                'is_group' => false,
                'type' => 'ai',
            ];
        }
        usort($items, fn (array $a, array $b) => (bool) ($b['is_pinned'] ?? false) <=> (bool) ($a['is_pinned'] ?? false));
        return response()->json($items);
    }

    private function aiParticipant(AiConversationService $ai): array
    {
        $user = User::with('profile')->find($ai->agent()->user_id);
        $data = $user?->toArray() ?? [];
        $data['display_name'] = 'My AI';
        $data['role'] = 'ai';
        $data['role_label'] = 'SwiftSnap AI';
        $data['is_verified'] = true;
        return $data;
    }
}
