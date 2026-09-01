<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (Schema::hasTable('my_ai_messages')) {
            return;
        }

        Schema::create('my_ai_messages', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('role', 20);
            $table->text('content');
            $table->string('provider', 60)->nullable();
            $table->string('model', 120)->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('my_ai_messages');
    }
};
