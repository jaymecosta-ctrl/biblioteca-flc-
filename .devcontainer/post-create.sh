#!/usr/bin/env bash
set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Instalar Composer se não existir
log_info "Verificando Composer..."
if ! command -v composer >/dev/null 2>&1; then
  log_info "Instalando Composer..."
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# Verificar se Composer foi instalado com sucesso
if ! composer --version >/dev/null 2>&1; then
  log_error "Composer não está disponível"
  exit 1
fi
log_info "Composer: $(composer --version)"

# Adicionar ao PATH
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Se não tiver artisan (projeto Laravel não existe), criar projeto
if [ ! -f "artisan" ]; then
  log_info "Criando projeto Laravel..."
  composer create-project laravel/laravel . --no-interaction --no-dev
else
  log_info "Projeto Laravel já existe"
fi

# Criar arquivo .env se não existir
if [ ! -f ".env" ]; then
  log_info "Criando arquivo .env..."
  cp .env.example .env
else
  log_info "Arquivo .env já existe"
fi

# Gerar chave da aplicação
log_info "Gerando chave da aplicação..."
php artisan key:generate --force || log_warn "Erro ao gerar chave (pode já existir)"

# Configurar banco de dados no .env
log_info "Configurando banco de dados..."
sed -i 's|^DB_HOST=.*|DB_HOST=db|g' .env
sed -i 's|^DB_PORT=.*|DB_PORT=3306|g' .env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE=laravel|g' .env
sed -i 's|^DB_USERNAME=.*|DB_USERNAME=root|g' .env
sed -i 's|^DB_PASSWORD=.*|DB_PASSWORD=root|g' .env

# Instalação opcional de dependências Node.js
if [ -f "package.json" ]; then
  log_info "Instalando dependências Node.js..."
  npm install --legacy-peer-deps || log_warn "npm install falhou (pode continuar)"
fi

# Executar migrations (opcional, pode falhar se DB não está pronto)
log_info "Tentando executar migrations..."
php artisan migrate --force || log_warn "Migrations falharam (DB pode não estar pronto ainda)"

log_info "✅ Ambiente configurado com sucesso!"
