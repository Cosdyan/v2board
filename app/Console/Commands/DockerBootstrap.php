<?php
namespace App\Console\Commands;
use App\Models\User;
use App\Utils\Helper;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
class DockerBootstrap extends Command {
    protected $signature = 'docker:bootstrap';
    protected $description = 'Initialize empty V2Board Docker database once';
    public function handle() {
        $email = getenv('BOOTSTRAP_ADMIN_EMAIL');
        $password = getenv('BOOTSTRAP_ADMIN_PASSWORD');
        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen((string)$password) < 12) {
            $this->error('Valid --email and at least 12-character --password required.');
            return 1;
        }
        try {
            DB::connection()->getPdo();
            $tableCount = DB::selectOne("SELECT COUNT(*) AS total FROM information_schema.tables WHERE table_schema = DATABASE()");
            if ((int)$tableCount->total > 0) {
                $this->error('Database already contains tables: refusing destructive SQL import.');
                return 1;
            }
            $sql = file_get_contents(database_path('install.sql'));
            if ($sql === false) throw new \RuntimeException('database/install.sql missing');
            $sql = preg_replace('/^\s*--[^\r\n]*$/m', '', $sql);
            $statements = preg_split('/;\s*(?:\r?\n|$)/', $sql);
            foreach ($statements as $statement) {
                if (trim($statement) !== '') DB::unprepared($statement);
            }
            $user = new User();
            $user->email = $email;
            $user->password = password_hash($password, PASSWORD_DEFAULT);
            $user->uuid = Helper::guid(true);
            $user->token = Helper::guid();
            $user->is_admin = 1;
            $user->save();
            $this->info('Database and administrator initialized.');
            return 0;
        } catch (\Throwable $e) {
            $this->error('Bootstrap failed: '.$e->getMessage());
            return 1;
        }
    }
}
