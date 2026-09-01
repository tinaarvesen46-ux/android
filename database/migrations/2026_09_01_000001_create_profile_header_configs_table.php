<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('profile_header_configs')) {
            Schema::create('profile_header_configs', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('user_id')->unique();
                $table->json('config')->nullable();
                $table->string('config_hash')->nullable()->index();
                $table->timestamps();
                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('profile_header_configs');
    }
};
