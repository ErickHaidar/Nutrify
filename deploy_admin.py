"""Admin Panel Deployment Script — upload admin folder + run commands on VPS."""
import os
import sys
import paramiko

VPS_IP = "103.253.212.55"
VPS_USER = "root"
VPS_PASS = "@Kikqthksbu19"
VPS_PATH = "/var/www/nutrify-admin"
LOCAL_ADMIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "admin")

EXCLUDE_DIRS = {"vendor", "node_modules", ".git", "storage/logs", "storage/framework"}
EXCLUDE_FILES = {".env"}

POST_COMMANDS = [
    "cd /var/www/nutrify-admin && cp .env.example .env",
    "cd /var/www/nutrify-admin && composer install --no-dev --optimize-autoloader",
    "cd /var/www/nutrify-admin && php artisan key:generate",
    "cd /var/www/nutrify-admin && php artisan migrate --force",
    "cd /var/www/nutrify-admin && php artisan storage:link",
    "cd /var/www/nutrify-admin && php artisan optimize:clear",
    "cd /var/www/nutrify-admin && php artisan config:cache",
    "cd /var/www/nutrify-admin && php artisan route:cache",
    "cd /var/www/nutrify-admin && php artisan view:cache",
    "cd /var/www/nutrify-admin && chown -R www-data:www-data /var/www/nutrify-admin/",
    "cd /var/www/nutrify-admin && php artisan tinker --execute=\"echo 'Admin users: ' . \\App\\Models\\Admin::count();\"",
]


def upload_directory(sftp, local_dir, remote_dir):
    """Recursively upload directory contents."""
    for item in os.listdir(local_dir):
        if item in EXCLUDE_DIRS:
            continue
        if item in EXCLUDE_FILES and local_dir == LOCAL_ADMIN:
            continue

        local_path = os.path.join(local_dir, item)
        rel_path = os.path.relpath(local_path, LOCAL_ADMIN)
        remote_path = os.path.join(remote_dir, rel_path).replace("\\", "/")

        if os.path.isdir(local_path):
            try:
                sftp.stat(remote_path)
            except FileNotFoundError:
                sftp.mkdir(remote_path)
            upload_directory(sftp, local_path, remote_dir)
        else:
            try:
                remote_dirname = os.path.dirname(remote_path).replace("\\", "/")
                try:
                    sftp.stat(remote_dirname)
                except FileNotFoundError:
                    sftp.mkdir(remote_dirname)
                sftp.put(local_path, remote_path)
                print(f"  OK: {rel_path}")
            except Exception as e:
                print(f"  FAIL: {rel_path} — {e}")


def run_commands(ssh):
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
    print("NUTRIFY ADMIN PANEL DEPLOYMENT")
    print(f"VPS: {VPS_USER}@{VPS_IP}")
    print(f"Target: {VPS_PATH}")
    print("=" * 60)

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(VPS_IP, username=VPS_USER, password=VPS_PASS, timeout=15)
        print("Connected.")
    except Exception as e:
        print(f"FAILED: {e}")
        sys.exit(1)

    sftp = ssh.open_sftp()

    # Ensure base directory exists
    try:
        sftp.stat(VPS_PATH)
    except FileNotFoundError:
        sftp.mkdir(VPS_PATH)
        print(f"Created {VPS_PATH}")

    print(f"\nUploading admin panel from {LOCAL_ADMIN}...")
    upload_directory(sftp, LOCAL_ADMIN, VPS_PATH)
    sftp.close()

    print("\n" + "=" * 60)
    print("POST-DEPLOY COMMANDS")
    print("=" * 60)
    run_commands(ssh)

    ssh.close()
    print("\n" + "=" * 60)
    print("DEPLOYMENT COMPLETE")
    print("Next: setup Nginx + SSL for admin.nutrify-app.web.id")
    print("=" * 60)


if __name__ == "__main__":
    main()
