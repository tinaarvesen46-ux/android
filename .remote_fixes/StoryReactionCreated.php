<?php

namespace App\Events;

use App\Models\StoryReaction;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class StoryReactionCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(StoryReaction $reaction)
    {
        $this->reaction = $reaction;
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('story.' . $this->reaction->story_id)];
    }

    public function broadcastAs(): string
    {
        return 'reaction.created';
    }

    public function broadcastWith(): array
    {
        $user = \App\Models\User::with('profile')->find($this->reaction->user_id);
        return [
            'reaction' => [
                'id' => (string) $this->reaction->id,
                'emoji' => $this->reaction->emoji ?? $this->reaction->reaction ?? null,
                'created_at' => $this->reaction->created_at->toIso8601String(),
                'user' => [
                    'id' => (int) $user->id,
                    'username' => $user->username,
                    'display_name' => $user->profile->display_name ?? null,
                    'avatar_url' => $user->profile->avatar_url ?? null,
                ],
            ],
        ];
    }
}
