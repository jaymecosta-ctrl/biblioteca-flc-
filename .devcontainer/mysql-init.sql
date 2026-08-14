cat > .devcontainer/mysql-init.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS laravel;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
EOF