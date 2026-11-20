# ======================================================================
# Programming with Gio
# Atalhos para gerenciamento do ambiente de desenvolvimento
# ======================================================================
#
# Exemplos:
#
# make setup
# make up
# make down
# make shell
# make check
#
# As linhas de comando abaixo de cada alvo devem começar com uma
# tabulação real. Espaços causam o erro "missing separator".
# ======================================================================


# ----------------------------------------------------------------------
# Configurações internas
# ----------------------------------------------------------------------

# Executável do Docker Compose utilizado por todos os comandos.
DOCKER_COMPOSE := docker compose

# Nome do serviço PHP definido no compose.yaml.
PHP_SERVICE := php

# Nome do serviço Nginx definido no compose.yaml.
NGINX_SERVICE := nginx

# Nome do serviço MySQL definido no compose.yaml.
MYSQL_SERVICE := mysql

# Executa comandos PHP com o usuário www-data.
#
# O UID e o GID do www-data foram alinhados aos do usuário do host
# durante a construção da imagem. Isso evita arquivos pertencentes
# ao root e avisos de propriedade do Git.
PHP_EXEC := $(DOCKER_COMPOSE) exec --user www-data $(PHP_SERVICE)

# Comando usado para executar o Composer no contêiner PHP.
COMPOSER := $(PHP_EXEC) composer


# ----------------------------------------------------------------------
# Configuração padrão
# ----------------------------------------------------------------------

# Executa "help" quando o make for chamado sem argumentos.
.DEFAULT_GOAL := help


# ----------------------------------------------------------------------
# Alvos que não representam arquivos
# ----------------------------------------------------------------------

.PHONY: help setup env config build rebuild up start stop down restart \
        recreate ps logs logs-php logs-nginx logs-mysql shell mysql-shell \
        php-version composer-version install require require-dev remove \
        update dump-autoload validate check-platform check audit \
        nginx-test php-config clean


# ======================================================================
# AJUDA
# ======================================================================

help:
	@printf '%s\n' \
		'' \
		'Programming with Gio' \
		'' \
		'Preparação:' \
		'  make setup                         Prepara e inicia todo o ambiente' \
		'  make env                           Cria o .env quando ele não existir' \
		'  make config                        Valida o compose.yaml' \
		'' \
		'Ambiente Docker:' \
		'  make build                         Constrói as imagens' \
		'  make rebuild                       Reconstrói as imagens sem cache' \
		'  make up                            Inicia os serviços' \
		'  make start                         Inicia contêineres existentes' \
		'  make stop                          Para os serviços sem removê-los' \
		'  make down                          Para e remove os contêineres' \
		'  make restart                       Reinicia os serviços' \
		'  make recreate                      Recria os contêineres' \
		'  make ps                            Exibe o estado dos serviços' \
		'' \
		'Logs:' \
		'  make logs                          Acompanha todos os logs' \
		'  make logs-php                      Acompanha os logs do PHP' \
		'  make logs-nginx                    Acompanha os logs do Nginx' \
		'  make logs-mysql                    Acompanha os logs do MySQL' \
		'' \
		'PHP e Composer:' \
		'  make shell                         Abre o shell do contêiner PHP' \
		'  make php-version                   Exibe a versão do PHP' \
		'  make composer-version              Exibe a versão do Composer' \
		'  make install                       Instala as dependências' \
		'  make require package=x             Instala um pacote da aplicação' \
		'  make require-dev package=x         Instala um pacote de desenvolvimento' \
		'  make remove package=x              Remove um pacote' \
		'  make update                        Atualiza as dependências' \
		'  make dump-autoload                 Regenera o autoload' \
		'' \
		'MySQL:' \
		'  make mysql-shell                   Abre o cliente MySQL' \
		'' \
		'Validações:' \
		'  make validate                      Valida o composer.json' \
		'  make check-platform                Verifica PHP e extensões' \
		'  make check                         Executa as verificações do projeto' \
		'  make audit                         Audita vulnerabilidades conhecidas' \
		'  make nginx-test                    Valida a configuração do Nginx' \
		'  make php-config                    Exibe os arquivos INI carregados' \
		'' \
		'Limpeza:' \
		'  make clean                         Remove contêineres, redes e volumes' \
		'                                     ATENÇÃO: apaga o banco MySQL local' \
		''


# ======================================================================
# PREPARAÇÃO INICIAL
# ======================================================================

# Executa a preparação completa:
#
# 1. cria o .env quando necessário;
# 2. valida o Compose;
# 3. constrói as imagens;
# 4. inicia os serviços;
# 5. instala as dependências PHP.
setup: env config build up install
	@. ./.env; \
	printf '%s\n' \
		'' \
		'Ambiente preparado com sucesso.' \
		"Aplicação disponível em: http://localhost:$${APP_PORT:-8080}" \
		''


# Cria o .env somente quando ele ainda não existir.
#
# Um arquivo existente nunca será sobrescrito automaticamente.
env:
	@if [ -f .env ]; then \
		echo 'O arquivo .env já existe.'; \
	else \
		cp .env.example .env; \
		echo 'Arquivo .env criado a partir de .env.example.'; \
	fi


# ======================================================================
# DOCKER COMPOSE
# ======================================================================

# Valida a sintaxe e a resolução do compose.yaml.
config:
	@$(DOCKER_COMPOSE) config --quiet
	@echo 'Configuração do Docker Compose válida.'


# Constrói as imagens utilizando o cache disponível.
build:
	$(DOCKER_COMPOSE) build


# Reconstrói todas as imagens sem utilizar cache.
#
# Esse processo pode demorar porque recompila as extensões PHP.
rebuild:
	$(DOCKER_COMPOSE) build --no-cache --progress=plain


# Cria e inicia os serviços em segundo plano.
up:
	$(DOCKER_COMPOSE) up -d


# Inicia contêineres existentes que estejam parados.
start:
	$(DOCKER_COMPOSE) start


# Para os contêineres sem removê-los.
stop:
	$(DOCKER_COMPOSE) stop


# Para e remove os contêineres e a rede do projeto.
#
# O volume do MySQL e seus dados são preservados.
down:
	$(DOCKER_COMPOSE) down


# Reinicia os serviços sem remover os contêineres.
restart:
	$(DOCKER_COMPOSE) restart


# Recria os contêineres preservando imagens e volumes.
recreate:
	$(DOCKER_COMPOSE) up -d --force-recreate


# Exibe o estado atual dos serviços.
ps:
	$(DOCKER_COMPOSE) ps


# ======================================================================
# LOGS
# ======================================================================

# Acompanha os logs de todos os serviços.
#
# Use Ctrl+C para sair. Os contêineres continuarão em execução.
logs:
	$(DOCKER_COMPOSE) logs --follow --tail=100


# Acompanha somente os logs do PHP.
logs-php:
	$(DOCKER_COMPOSE) logs --follow --tail=100 $(PHP_SERVICE)


# Acompanha somente os logs do Nginx.
logs-nginx:
	$(DOCKER_COMPOSE) logs --follow --tail=100 $(NGINX_SERVICE)


# Acompanha somente os logs do MySQL.
logs-mysql:
	$(DOCKER_COMPOSE) logs --follow --tail=100 $(MYSQL_SERVICE)


# ======================================================================
# PHP
# ======================================================================

# Abre o shell disponível na imagem Alpine do PHP.
shell:
	$(PHP_EXEC) sh


# Exibe a versão do PHP utilizada pelo projeto.
php-version:
	$(PHP_EXEC) php --version


# Exibe os arquivos de configuração carregados pelo PHP.
php-config:
	$(PHP_EXEC) php --ini


# ======================================================================
# COMPOSER
# ======================================================================

# Exibe a versão do Composer.
composer-version:
	$(COMPOSER) --version


# Instala as dependências registradas no composer.lock.
install:
	$(COMPOSER) install


# Instala uma dependência utilizada pela aplicação.
#
# Exemplo:
#
# make require package=ramsey/uuid
require:
	@test -n "$(package)" || { \
		echo 'Informe o pacote que deseja instalar.'; \
		echo 'Exemplo: make require package=ramsey/uuid'; \
		exit 1; \
	}
	$(COMPOSER) require "$(package)"


# Instala uma dependência usada somente no desenvolvimento.
#
# Exemplo:
#
# make require-dev package=phpunit/phpunit
require-dev:
	@test -n "$(package)" || { \
		echo 'Informe o pacote de desenvolvimento.'; \
		echo 'Exemplo: make require-dev package=phpunit/phpunit'; \
		exit 1; \
	}
	$(COMPOSER) require --dev "$(package)"


# Remove um pacote do projeto.
#
# Exemplo:
#
# make remove package=ramsey/uuid
remove:
	@test -n "$(package)" || { \
		echo 'Informe o pacote que deseja remover.'; \
		echo 'Exemplo: make remove package=ramsey/uuid'; \
		exit 1; \
	}
	$(COMPOSER) remove "$(package)"


# Atualiza todas as dependências permitidas pelo composer.json.
#
# Esse comando modifica o composer.lock.
# Para uma instalação normal, prefira "make install".
update:
	$(COMPOSER) update


# Regenera os arquivos de autoload.
dump-autoload:
	$(COMPOSER) dump-autoload


# ======================================================================
# MYSQL
# ======================================================================

# Abre o cliente MySQL utilizando o usuário e o banco definidos
# dentro do contêiner MySQL.
#
# A senha é lida da variável MYSQL_PASSWORD do próprio contêiner.
mysql-shell:
	$(DOCKER_COMPOSE) exec $(MYSQL_SERVICE) sh -c \
		'mysql \
			--user="$$MYSQL_USER" \
			--password="$$MYSQL_PASSWORD" \
			"$$MYSQL_DATABASE"'


# ======================================================================
# VALIDAÇÕES E SEGURANÇA
# ======================================================================

# Valida a estrutura e a consistência do composer.json.
validate:
	$(COMPOSER) validate --strict


# Verifica a versão do PHP e as extensões exigidas.
check-platform:
	$(COMPOSER) check-platform-reqs


# Executa o script "check" definido no composer.json.
check:
	$(COMPOSER) check


# Verifica vulnerabilidades nas dependências externas.
#
# Quando o composer.lock não contém pacotes externos, a auditoria
# é ignorada porque não há dependências para verificar.
#
# Quando houver pacotes, o código de saída do Composer será mantido.
# Vulnerabilidades ou erros reais continuarão fazendo o alvo falhar.
audit:
	@if $(PHP_EXEC) php -r '$$lock = json_decode(file_get_contents("composer.lock"), true); exit(empty($$lock["packages"]) && empty($$lock["packages-dev"]) ? 0 : 1);'; then \
		echo 'Nenhum pacote externo encontrado. Auditoria não necessária.'; \
	else \
		$(COMPOSER) audit --locked; \
	fi


# Valida a configuração do Nginx.
nginx-test:
	$(DOCKER_COMPOSE) exec $(NGINX_SERVICE) nginx -t


# ======================================================================
# LIMPEZA
# ======================================================================

# Remove:
#
# - contêineres;
# - rede do projeto;
# - contêineres órfãos;
# - volumes Docker do projeto.
#
# ATENÇÃO:
#
# Como o MySQL utiliza o volume mysql-data, este comando também
# apagará permanentemente o banco de dados local.
#
# Para desligar preservando o banco, utilize:
#
# make down
clean:
	@printf '%s\n' \
		'ATENÇÃO: este comando removerá os volumes e apagará o banco MySQL local.'
	@printf 'Digite REMOVER para continuar: '
	@read confirmation; \
	if [ "$$confirmation" != 'REMOVER' ]; then \
		echo 'Limpeza cancelada.'; \
		exit 1; \
	fi
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
