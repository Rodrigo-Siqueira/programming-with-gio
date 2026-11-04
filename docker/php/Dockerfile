# syntax=docker/dockerfile:1

# ----------------------------------------------------------------------
# Estágio auxiliar: Composer
# ----------------------------------------------------------------------
# Utilizamos a imagem oficial do Composer apenas para copiar o executável.
# O conteúdo restante dessa imagem não será incluído na imagem final.
FROM composer:2 AS composer

# ----------------------------------------------------------------------
# Imagem principal: PHP-FPM
# ----------------------------------------------------------------------
# PHP 8.5:
#   Linha estável utilizada pela estação.
#
# FPM:
#   Permite que o Nginx encaminhe requisições PHP via FastCGI.
#
# Alpine:
#   Sistema-base compacto utilizado pelo contêiner.
FROM php:8.5-fpm-alpine

# ----------------------------------------------------------------------
# Metadados
# ----------------------------------------------------------------------
LABEL org.opencontainers.image.title="PHP Docker Starter"
LABEL org.opencontainers.image.description="Ambiente base para desenvolvimento de aplicações PHP"

# ----------------------------------------------------------------------
# Bibliotecas necessárias durante a execução
# ----------------------------------------------------------------------
# icu-libs:
#   Bibliotecas utilizadas pela extensão intl.
#
# libzip:
#   Biblioteca utilizada pela extensão zip.
#
# --no-cache:
#   Não mantém o índice do gerenciador de pacotes dentro da imagem.
RUN apk add --no-cache \
    icu-libs \
    libzip

# ----------------------------------------------------------------------
# Dependências necessárias somente durante a compilação
# ----------------------------------------------------------------------
# icu-dev:
#   Cabeçalhos necessários para compilar intl.
#
# libzip-dev:
#   Cabeçalhos necessários para compilar zip.
#
# O grupo virtual .build-deps facilita a remoção dessas dependências
# depois que as extensões forem compiladas.
RUN apk add --no-cache --virtual .build-deps \
    icu-dev \
    libzip-dev

# ----------------------------------------------------------------------
# Configuração da extensão intl
# ----------------------------------------------------------------------
# A configuração explícita facilita a identificação de possíveis
# incompatibilidades com a biblioteca ICU.
RUN docker-php-ext-configure intl

# ----------------------------------------------------------------------
# Extensões PHP adicionais
# ----------------------------------------------------------------------
# intl:
#   Internacionalização, moedas, datas e normalização Unicode.
#
# pdo_mysql:
#   Driver PDO para conexão com MySQL e MariaDB.
#
# zip:
#   Manipulação de arquivos ZIP.
#
# O OPcache não aparece nesta lista porque, desde o PHP 8.5,
# ele faz parte obrigatoriamente do PHP e não deve ser compilado
# novamente com docker-php-ext-install.
RUN docker-php-ext-install -j"$(nproc)" \
    intl \
    pdo_mysql \
    zip

# ----------------------------------------------------------------------
# Limpeza das dependências de compilação
# ----------------------------------------------------------------------
# Remove os pacotes utilizados apenas durante a compilação.
# As bibliotecas necessárias durante a execução permanecem instaladas.
RUN apk del .build-deps \
    && rm -rf /tmp/*

# ----------------------------------------------------------------------
# Composer
# ----------------------------------------------------------------------
# Copia somente o executável do Composer do estágio auxiliar.
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# ----------------------------------------------------------------------
# Configuração personalizada do PHP
# ----------------------------------------------------------------------
# O PHP carrega automaticamente arquivos INI presentes em conf.d.
# O prefixo 99 faz o arquivo ser carregado depois das configurações padrão.
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-app.ini

# ----------------------------------------------------------------------
# Diretório de trabalho
# ----------------------------------------------------------------------
# Os comandos executados no contêiner partirão deste diretório.
WORKDIR /var/www/html

# ----------------------------------------------------------------------
# Porta interna
# ----------------------------------------------------------------------
# Esta instrução apenas documenta a porta utilizada pelo PHP-FPM.
# Ela não publica a porta no Linux Mint.
EXPOSE 9000

# ----------------------------------------------------------------------
# Processo principal
# ----------------------------------------------------------------------
# Executa o PHP-FPM em primeiro plano.
CMD ["php-fpm", "-F"]