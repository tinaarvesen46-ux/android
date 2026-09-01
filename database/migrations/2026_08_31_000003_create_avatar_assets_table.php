<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('avatar_assets')) {
            Schema::create('avatar_assets', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->string('asset_id')->unique();
                $table->string('category')->index();
                $table->string('filename');
                $table->string('mime')->nullable();
                $table->json('meta')->nullable();
                $table->boolean('enabled')->default(true);
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('avatar_assets');
    }
};
