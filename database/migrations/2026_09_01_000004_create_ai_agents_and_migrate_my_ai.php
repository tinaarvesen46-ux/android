<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration {
    public function up(): void
    {
        if (! Schema::hasTable('ai_agents')) {
            Schema::create('ai_agents', function (Blueprint $table): void {
                $table->id();
                $table->string('key', 60)->unique();
                $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
                $table->string('provider', 60)->default('none');
                $table->string('base_url', 500)->nullable();
                $table->string('model', 120)->nullable();
                $table->boolean('is_enabled')->default(true);
                $table->json('metadata')->nullable();
                $table->timestamps();
            });
        }

        $email = 'my-ai@swiftsnap.internal';
        $agentUser = DB::table('users')->where('email', $email)->first();
        if (! $agentUser) {
            $username = 'myai';
            if (DB::table('users')->where('username', $username)->exists()) $username = 'myai_swiftsnap';
            $id = DB::table('users')->insertGetId([
                'uuid' => (string) Str::uuid(),
                'username' => $username,
                'email' => $email,
                'password' => Hash::make(Str::random(64)),
                'account_status' => 'verified',
                'staff_role' => 'none',
                'privacy_level' => 'private',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $agentUser = DB::table('users')->where('id', $id)->first();
        }
        DB::table('ai_agents')->updateOrInsert(
            ['key' => 'my_ai'],
            ['user_id' => $agentUser->id, 'provider' => 'none', 'is_enabled' => true, 'updated_at' => now(), 'created_at' => now()]
        );

        // Move any temporary My AI rows into the normal messages graph before
        // removing that transitional table. This is idempotent by migration.
        if (Schema::hasTable('my_ai_messages')) {
            $agentId = (int) $agentUser->id;
            $users = DB::table('my_ai_messages')->select('user_id')->distinct()->pluck('user_id');
            foreach ($users as $userId) {
                $conversation = DB::table('conversations')->where('type', 'ai')->where('created_by', $userId)->first();
                if (! $conversation) {
                    $conversationId = DB::table('conversations')->insertGetId([
                        'uuid' => (string) Str::uuid(), 'type' => 'ai', 'name' => 'My AI',
                        'created_by' => $userId, 'max_participants' => 2,
                        'last_activity_at' => now(), 'created_at' => now(), 'updated_at' => now(),
                    ]);
                    DB::table('conversation_participants')->insert([
                        ['conversation_id' => $conversationId, 'user_id' => $userId, 'role' => 'owner', 'is_pinned' => 1, 'joined_at' => now()],
                        ['conversation_id' => $conversationId, 'user_id' => $agentId, 'role' => 'member', 'joined_at' => now()],
                    ]);
                    $conversation = DB::table('conversations')->where('id', $conversationId)->first();
                }
                foreach (DB::table('my_ai_messages')->where('user_id', $userId)->orderBy('id')->get() as $old) {
                    $senderId = $old->role === 'assistant' ? $agentId : $userId;
                    DB::table('messages')->insert([
                        'uuid' => (string) Str::uuid(), 'conversation_id' => $conversation->id,
                        'sender_id' => $senderId, 'type' => 'text', 'content' => $old->content,
                        'status' => 'sent', 'delivered_at' => now(), 'created_at' => $old->created_at ?: now(),
                    ]);
                }
            }
            Schema::dropIfExists('my_ai_messages');
        }
    }

    public function down(): void
    {
        // Keep the system user and any normal chat history intact on rollback.
        Schema::dropIfExists('ai_agents');
    }
};
