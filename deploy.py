"""Sprint 3 Deployment Script — upload files + run commands on VPS."""
import os
import sys
import paramiko

VPS_IP = "103.253.212.55"
VPS_USER = "root"
VPS_PASS = "@Kikqthksbu19"
VPS_PATH = "/var/www/nutrify-app"
LOCAL_BASE = os.path.dirname(os.path.abspath(__file__))

FILES_TO_UPLOAD = [
    # Modified backend files
    "backend/app/Models/Food.php",
    "backend/app/Models/WeightLog.php",
    "backend/app/Http/Controllers/Api/FollowController.php",
    "backend/app/Http/Controllers/Api/PostController.php",
    "backend/app/Http/Controllers/Api/ProgressController.php",
    "backend/app/Http/Middleware/VerifySupabaseToken.php",
    "backend/routes/api.php",
    "backend/database/seeders/StudentFoodSeeder.php",
    # New backend files
    "backend/app/Models/PostReport.php",
    "backend/app/Console/Commands/CleanFoods.php",
    "backend/app/Console/Commands/ImportFoods.php",
    "backend/database/migrations/2026_06_01_000001_add_index_to_weight_logs_table.php",
    "backend/database/migrations/2026_06_01_000002_create_post_reports_table.php",
    "backend/database/migrations/2026_06_01_000003_add_hidden_to_posts_table.php",
    "backend/database/migrations/2026_06_01_000004_add_category_to_foods_table.php",
    # Dataset
    "dataset_pipeline/output/foods_id_clean.csv",
]

POST_COMMANDS = [
    "cd /var/www/nutrify-app/backend && chown -R www-data:www-data /var/www/nutrify-app/",
    "cd /var/www/nutrify-app/backend && php artisan migrate --force",
    "cd /var/www/nutrify-app/backend && php artisan foods:import --file=/var/www/nutrify-app/dataset_pipeline/output/foods_id_clean.csv",
    "cd /var/www/nutrify-app/backend && php artisan optimize:clear",
    "cd /var/www/nutrify-app/backend && php artisan config:cache",
    "cd /var/www/nutrify-app/backend && php artisan route:cache",
    "cd /var/www/nutrify-app/backend && php artisan route:list 2>/dev/null | grep -E 'validate|progress|report'",
    "cd /var/www/nutrify-app/backend && php artisan tinker --execute=\"echo 'Total foods: ' . \\App\\Models\\Food::count();\"",
]


def upload_files(ssh: paramiko.SSHClient):
    """Upload all files via SFTP."""
    sftp = ssh.open_sftp()

    for rel_path in FILES_TO_UPLOAD:
        local_path = os.path.join(LOCAL_BASE, rel_path)
        remote_path = f"{VPS_PATH}/{rel_path}"

        if not os.path.exists(local_path):
            print(f"  SKIP (not found): {rel_path}")
            continue

        # Ensure remote directory exists
        remote_dir = os.path.dirname(remote_path)
        try:
            sftp.stat(remote_dir)
        except FileNotFoundError:
            # Create directory recursively
            parts = remote_dir.replace(VPS_PATH + "/", "").split("/")
            current = VPS_PATH
            for part in parts:
                current = f"{current}/{part}"
                try:
                    sftp.stat(current)
                except FileNotFoundError:
                    sftp.mkdir(current)

        sftp.put(local_path, remote_path)
        size_kb = os.path.getsize(local_path) / 1024
        print(f"  OK: {rel_path} ({size_kb:.1f} KB)")

    sftp.close()


def run_commands(ssh: paramiko.SSHClient):
    """Run post-deploy commands."""
    for cmd in POST_COMMANDS:
        print(f"\n$ {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=120)
        out = stdout.read().decode()
        err = stderr.read().decode()
        if out:
            print(out.strip())
        if err:
            print(f"  STDERR: {err.strip()[:300]}")


def main():
    print("=" * 60)
    print("NUTRIFY SPRINT 3 DEPLOYMENT")
    print(f"VPS: {VPS_USER}@{VPS_IP}")
    print("=" * 60)

    # Connect
    print("\nConnecting to VPS...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(VPS_IP, username=VPS_USER, password=VPS_PASS, timeout=15)
        print("  Connected.")
    except Exception as e:
        print(f"  FAILED: {e}")
        sys.exit(1)

    # Upload
    print(f"\nUploading {len(FILES_TO_UPLOAD)} files...")
    upload_files(ssh)

    # Post-deploy
    print("\n" + "=" * 60)
    print("RUNNING POST-DEPLOY COMMANDS")
    print("=" * 60)
    run_commands(ssh)

    ssh.close()
    print("\n" + "=" * 60)
    print("DEPLOYMENT COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
