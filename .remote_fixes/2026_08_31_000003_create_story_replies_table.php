<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('story_replies', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('story_id');
            $table->unsignedBigInteger('message_id')->nullable();
            $table->unsignedBigInteger('user_id');
            $table->text('content');
            $table->timestamps();

            $table->foreign('story_id')->references('id')->on('stories')->onDelete('cascade');
            $table->foreign('message_id')->references('id')->on('messages')->onDelete('set null');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('story_replies');
    }
};
