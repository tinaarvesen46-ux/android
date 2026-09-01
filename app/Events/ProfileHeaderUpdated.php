<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ProfileHeaderUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public int $userId;
    public $config;

    public function __construct(int $userId, $config)
    {
        $this->userId = $userId;
        $this->config = $config;
    }

    public function broadcastOn(): PrivateChannel
    {
        return new PrivateChannel('user.' . $this->userId);
    }

    public function broadcastWith(): array
    {
        return [
            'type' => 'ProfileHeaderUpdated',
            'config' => $this->config,
            'user_id' => $this->userId,
            'timestamp' => now()->timestamp,
        ];
    }

    public function broadcastAs(): string
    {
        return 'ProfileHeaderUpdated';
    }
}
