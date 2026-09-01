<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Queue\SerializesModels;

class AvatarUpdated implements ShouldBroadcast
{
    use InteractsWithSockets, SerializesModels;

    public int $userId;
    public array $config;
    public ?string $avatarUrl;

    public function __construct(int $userId, ?array $config, ?string $avatarUrl = null)
    {
        $this->userId = $userId;
        $this->config = $config;
        $this->avatarUrl = $avatarUrl;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->userId);
    }

    public function broadcastWith()
    {
        return [
            'user_id' => $this->userId,
            'config' => $this->config,
            'avatar_url' => $this->avatarUrl,
            'updated_at' => now()->toDateTimeString(),
            'timestamp' => now()->timestamp,
        ];
    }

    public function broadcastAs()
    {
        return 'AvatarUpdated';
    }
}
