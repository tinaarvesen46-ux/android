<?php

namespace App\Events;

use App\Models\StoryReply;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class StoryReplyCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(StoryReply $reply)
    {
        $this->reply = $reply;
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('story.' . $this->reply->story_id)];
    }

    public function broadcastAs(): string
    {
        return 'reply.created';
    }

    public function broadcastWith(): array
    {
        $author = \App\Models\User::with('profile')->find($this->reply->user_id);
        return [
            'reply' => [
                'id' => (string) $this->reply->id,
                'content' => $this->reply->content,
                'created_at' => $this->reply->created_at->toIso8601String(),
                'author' => [
                    'id' => (int) $author->id,
                    'username' => $author->username,
                    'display_name' => $author->profile->display_name ?? null,
                    'avatar_url' => $author->profile->avatar_url ?? null,
                ],
            ],
        ];
    }
}
