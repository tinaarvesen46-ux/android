<?php

namespace App\Services;

use App\Events\MessageSent;
use App\Models\AiAgent;
use App\Models\Conversation;
use App\Models\ConversationParticipant;
use App\Models\Message;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

/** Owns My AI's identity and maps it onto the normal chat graph. */
class AiConversationService
{
    public function agent(): AiAgent
    {
        $agent = AiAgent::where('key', 'my_ai')->where('is_enabled', true)->first();
        if (! $agent) {
            throw new RuntimeException('My AI is not enabled on this server.');
        }
        return $agent;
    }

    public function conversationFor(int $userId): Conversation
    {
        $agent = $this->agent();
        $conversation = Conversation::where('type', 'ai')
            ->where('created_by', $userId)
            ->whereIn('id', function ($query) use ($agent) {
                $query->select('conversation_id')
                    ->from('conversation_participants')
                    ->where('user_id', $agent->user_id)
                    ->whereNull('left_at');
            })
            ->first();

        if ($conversation) {
            ConversationParticipant::where('conversation_id', $conversation->id)
                ->where('user_id', $userId)
                ->update(['is_pinned' => true]);
            return $conversation;
        }

        return DB::transaction(function () use ($userId, $agent) {
            $conversation = Conversation::create([
                'uuid' => (string) Str::uuid(),
                'type' => 'ai',
                'name' => 'My AI',
                'avatar_url' => null,
                'created_by' => $userId,
                'max_participants' => 2,
                'last_activity_at' => now(),
            ]);
            ConversationParticipant::create([
                'conversation_id' => $conversation->id,
                'user_id' => $userId,
                'role' => 'owner',
                'joined_at' => now(),
            ]);
            ConversationParticipant::where('conversation_id', $conversation->id)
                ->where('user_id', $userId)
                ->update(['is_pinned' => true]);
            ConversationParticipant::create([
                'conversation_id' => $conversation->id,
                'user_id' => $agent->user_id,
                'role' => 'member',
                'joined_at' => now(),
            ]);
            return $conversation;
        });
    }

    public function history(int $userId): array
    {
        $conversation = $this->conversationFor($userId);
        $agent = $this->agent();
        return Message::where('conversation_id', $conversation->id)
            ->orderBy('id')
            ->limit(100)
            ->get(['id', 'sender_id', 'content', 'created_at'])
            ->map(fn (Message $message) => [
                'id' => (string) $message->id,
                'role' => (int) $message->sender_id === (int) $agent->user_id ? 'assistant' : 'user',
                'content' => (string) $message->content,
                'created_at' => $message->created_at,
            ])->all();
    }

    public function send(int $userId, string $prompt): string
    {
        $conversation = $this->conversationFor($userId);
        $agent = $this->agent();
        $userMessage = DB::transaction(function () use ($conversation, $userId, $prompt) {
            $message = Message::create([
                'uuid' => (string) Str::uuid(),
                'conversation_id' => $conversation->id,
                'sender_id' => $userId,
                'type' => 'text',
                'content' => $prompt,
                'status' => 'sent',
                'delivered_at' => now(),
            ]);
            Conversation::whereKey($conversation->id)->update([
                'last_message_id' => $message->id,
                'last_activity_at' => now(),
            ]);
            return $message;
        });
        try { broadcast(new MessageSent($userMessage)); } catch (\Throwable $e) {}

        $reply = app(MyAiService::class)->reply($prompt, $agent);
        $assistantMessage = DB::transaction(function () use ($conversation, $agent, $reply) {
            $message = Message::create([
                'uuid' => (string) Str::uuid(),
                'conversation_id' => $conversation->id,
                'sender_id' => $agent->user_id,
                'type' => 'text',
                'content' => $reply,
                'status' => 'sent',
                'delivered_at' => now(),
            ]);
            Conversation::whereKey($conversation->id)->update([
                'last_message_id' => $message->id,
                'last_activity_at' => now(),
            ]);
            return $message;
        });
        try { broadcast(new MessageSent($assistantMessage)); } catch (\Throwable $e) {}
        return $reply;
    }
}
