<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('conversations') || !Schema::hasColumn('conversations', 'type')) {
            return;
        }

        // The original schema used ENUM('direct','group'). A VARCHAR keeps all
        // existing values intact and allows the reserved 'ai' system type.
        DB::statement("ALTER TABLE conversations MODIFY type VARCHAR(20) NOT NULL DEFAULT 'direct'");
    }

    public function down(): void
    {
        if (!Schema::hasTable('conversations') || !Schema::hasColumn('conversations', 'type')) {
            return;
        }

        if (DB::table('conversations')->where('type', 'ai')->exists()) {
            throw new RuntimeException('Cannot restore conversation enum while ai conversations exist.');
        }

        DB::statement("ALTER TABLE conversations MODIFY type ENUM('direct','group') NOT NULL DEFAULT 'direct'");
    }
};
