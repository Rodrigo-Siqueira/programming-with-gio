# ======================================================================
# PHP Docker Starter
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

# Comando usado para executar processos no contêiner PHP ativo.
PHP_EXEC := $(DOCKER_COMPOSE) exec $(PHP_SERVICE)

# Comando usado para executar o Composer no contêiner PHP.
COMPOSER := $(PHP_EXEC) composer


# ----------------------------------------------------------------------
# Configuração padrão
# ----------------------------------------------------------------------

# Executa "help" quando o comando "make" for chamado sem argumentos.
.DEFAULT_GOAL := help


# ----------------------------------------------------------------------
# Alvos que não representam arquivos
# ----------------------------------------------------------------------
# Esta declaração impede que um arquivo chamado "up", "build" ou
# semelhante faça o Make considerar o alvo como já concluído.
.PHONY: help setup env config build rebuild up start stop down restart \
        recreate ps logs logs-php logs-nginx shell php-version \
        composer-version install update dump-autoload validate \
        check-platform check audit nginx-test php-config clean


# ----------------------------------------------------------------------
# Ajuda
# ----------------------------------------------------------------------

help:
	@printf '%s\n' \
		'' \
		'PHP Docker Starter' \
		'' \
		'Preparação:' \
		'  make setup             Prepara o .env, constrói e inicia o ambiente' \
		'  make env               Cria o .env quando ele ainda não existir' \
		'  make config            Valida o compose.yaml' \
		'' \
		'Ambiente Docker:' \
		'  make build             Constrói as imagens' \
		'  make rebuild           Reconstrói as imagens sem utilizar cache' \
		'  make up                Inicia os serviços em segundo plano' \
		'  make start             Inicia serviços que estejam parados' \
		'  make stop              Para os serviços sem removê-los' \
		'  make down              Para e remove os serviços' \
		'  make restart           Reinicia todo o ambiente' \
		'  make recreate          Recria os contêineres' \
		'  make ps                Exibe o estado dos serviços' \
		'' \
		'Logs:' \
		'  make logs              Acompanha os logs de todos os serviços' \
		'  make logs-php          Acompanha somente os logs do PHP' \
		'  make logs-nginx        Acompanha somente os logs do Nginx' \
		'' \
		'PHP e Composer:' \
		'  make shell             Abre o terminal do contêiner PHP' \
		'  make php-version       Exibe a versão do PHP' \
		'  make composer-version  Exibe a versão do Composer' \
		'  make install           Instala as dependências do Composer' \
		'  make update            Atualiza as dependências do Composer' \
		'  make dump-autoload     Regenera o autoload do Composer' \
		'' \
		'Validações:' \
		'  make validate          Valida o composer.json' \
		'  make check-platform    Verifica PHP e extensões necessárias' \
		'  make check             Executa as verificações do projeto' \
		'  make audit             Audita vulnerabilidades conhecidas' \
		'  make nginx-test        Valida a configuração do Nginx' \
		'  make php-config        Exibe os arquivos INI carregados' \
		'' \
		'Limpeza:' \
		'  make clean             Remove contêineres, redes e volumes locais' \
		''


# ----------------------------------------------------------------------
# Preparação inicial
# ----------------------------------------------------------------------

# Executa a preparação completa para uma nova instalação.
#
# Ordem:
# 1. cria o arquivo .env quando necessário;
# 2. valida o compose.yaml;
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


# Cria o arquivo .env somente quando ele ainda não existir.
#
# O arquivo existente nunca será sobrescrito automaticamente.
env:
	@if [ -f .env ]; then \
		echo 'O arquivo .env já existe.'; \
	else \
		cp .env.example .env; \
		echo 'Arquivo .env criado a partir de .env.example.'; \
	fi


# ----------------------------------------------------------------------
# Docker Compose
# ----------------------------------------------------------------------

# Valida a sintaxe e a resolução do compose.yaml.
config:
	@$(DOCKER_COMPOSE) config --quiet
	@echo 'Configuração do Docker Compose válida.'


# Constrói as imagens utilizando o cache disponível.
build:
	$(DOCKER_COMPOSE) build


# Reconstrói todas as imagens sem utilizar o cache.
#
# Este comando pode demorar porque recompila as extensões PHP.
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


# Para e remove contêineres e redes criados pelo Compose.
#
# Os arquivos do projeto não são removidos.
down:
	$(DOCKER_COMPOSE) down


# Reinicia os serviços sem remover os contêineres.
restart:
	$(DOCKER_COMPOSE) restart


# Recria os contêineres preservando as imagens existentes.
recreate:
	$(DOCKER_COMPOSE) up -d --force-recreate


# Exibe o estado atual dos serviços.
ps:
	$(DOCKER_COMPOSE) ps


# ----------------------------------------------------------------------
# Logs
# ----------------------------------------------------------------------

# Acompanha os logs de todos os serviços.
#
# Use Ctrl+C para sair sem parar os contêineres.
logs:
	$(DOCKER_COMPOSE) logs --follow --tail=100


# Acompanha somente os logs do serviço PHP.
logs-php:
	$(DOCKER_COMPOSE) logs --follow --tail=100 $(PHP_SERVICE)


# Acompanha somente os logs do serviço Nginx.
logs-nginx:
	$(DOCKER_COMPOSE) logs --follow --tail=100 $(NGINX_SERVICE)


# ----------------------------------------------------------------------
# PHP e Composer
# ----------------------------------------------------------------------

# Abre o shell disponível na imagem Alpine do contêiner PHP.
shell:
	$(PHP_EXEC) sh


# Exibe a versão do PHP utilizada pelo projeto.
php-version:
	$(PHP_EXEC) php --version


# Exibe a versão do Composer instalada na imagem PHP.
composer-version:
	$(COMPOSER) --version


# Instala as dependências registradas no composer.lock.
install:
	$(COMPOSER) install


# Atualiza as dependências e modifica o composer.lock.
#
# Use este comando intencionalmente. Para instalações normais,
# prefira "make install".
update:
	$(COMPOSER) update


# Regenera os arquivos de autoload.
dump-autoload:
	$(COMPOSER) dump-autoload


# ----------------------------------------------------------------------
# Validações e segurança
# ----------------------------------------------------------------------

# Valida a estrutura e a consistência do composer.json.
validate:
	$(COMPOSER) validate --strict


# Verifica a versão do PHP e as extensões exigidas pelo projeto.
check-platform:
	$(COMPOSER) check-platform-reqs


# Executa o script "check" definido no composer.json.
check:
	$(COMPOSER) check


# Verifica vulnerabilidades conhecidas nas dependências externas.
#
# Quando o composer.lock não contém pacotes externos, a auditoria
# é ignorada porque não há dependências para verificar.
#
# Quando houver pacotes, o código de saída do Composer será preservado.
# Assim, vulnerabilidades reais continuarão fazendo o comando falhar.
audit:
	@if $(PHP_EXEC) php -r '$$lock = json_decode(file_get_contents("composer.lock"), true); exit(empty($$lock["packages"]) && empty($$lock["packages-dev"]) ? 0 : 1);'; then \
		echo 'Nenhum pacote externo encontrado. Auditoria não necessária.'; \
	else \
		$(COMPOSER) audit --locked; \
	fi


# Valida a configuração do Nginx dentro do contêiner ativo.
nginx-test:
	$(DOCKER_COMPOSE) exec $(NGINX_SERVICE) nginx -t


# Exibe os arquivos de configuração carregados pelo PHP.
php-config:
	$(PHP_EXEC) php --ini


# ----------------------------------------------------------------------
# Limpeza
# ----------------------------------------------------------------------

# Remove contêineres, redes e volumes locais criados pelo Compose.
#
# Este comando não remove:
#
# - arquivos do projeto;
# - imagens Docker;
# - dependências em vendor;
# - composer.lock.
clean:
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
