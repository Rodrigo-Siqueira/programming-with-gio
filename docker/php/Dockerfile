# syntax=docker/dockerfile:1

# ----------------------------------------------------------------------
# Estágio auxiliar: Composer
# ----------------------------------------------------------------------
# Utiliza a imagem oficial somente para obter o executável do Composer.
FROM composer:2 AS composer

# ----------------------------------------------------------------------
# Imagem principal: PHP-FPM
# ----------------------------------------------------------------------
# PHP-FPM recebe as requisições encaminhadas pelo Nginx via FastCGI.
FROM php:8.5-fpm-alpine

# ----------------------------------------------------------------------
# Metadados
# ----------------------------------------------------------------------
LABEL org.opencontainers.image.title="PHP Docker Starter"
LABEL org.opencontainers.image.description="Ambiente base para desenvolvimento de aplicações PHP"

# ----------------------------------------------------------------------
# Alinhamento do usuário do contêiner com o usuário do host
# ----------------------------------------------------------------------
# O PHP-FPM executa como www-data.
#
# O alinhamento de UID e GID evita que arquivos criados pelo PHP
# dentro do bind mount pertençam ao usuário root no Linux.
ARG HOST_UID=1000
ARG HOST_GID=1000

# shadow fornece groupmod e usermod no Alpine.
#
# O pacote é removido depois da alteração porque não é necessário
# durante a execução da aplicação.
RUN apk add --no-cache shadow \
    && groupmod -g "${HOST_GID}" www-data \
    && usermod -u "${HOST_UID}" -g "${HOST_GID}" www-data \
    && apk del shadow

# ----------------------------------------------------------------------
# Ferramentas e bibliotecas necessárias durante a execução
# ----------------------------------------------------------------------
# git:
#   Permite ao Composer obter pacotes por repositórios Git.
#
# unzip:
#   Permite ao Composer extrair pacotes distribuídos em ZIP.
#
# icu-libs:
#   Bibliotecas utilizadas pela extensão intl.
#
# libzip:
#   Biblioteca utilizada pela extensão zip.
RUN apk add --no-cache \
    git \
    unzip \
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
# O grupo virtual .build-deps será removido depois da compilação.
RUN apk add --no-cache --virtual .build-deps \
    icu-dev \
    libzip-dev

# ----------------------------------------------------------------------
# Extensões PHP
# ----------------------------------------------------------------------
# intl:
#   Internacionalização, moedas, datas e normalização Unicode.
#
# pdo_mysql:
#   Driver PDO utilizado para conexões com MySQL e MariaDB.
#
# zip:
#   Manipulação de arquivos ZIP.
#
# No PHP 8.5, o OPcache já faz parte do PHP e não deve ser compilado
# novamente com docker-php-ext-install.
RUN docker-php-ext-install -j"$(nproc)" \
    intl \
    pdo_mysql \
    zip

# ----------------------------------------------------------------------
# Limpeza das dependências de compilação
# ----------------------------------------------------------------------
RUN apk del .build-deps \
    && rm -rf /tmp/*

# ----------------------------------------------------------------------
# Composer
# ----------------------------------------------------------------------
# Copia somente o executável do estágio auxiliar.
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# ----------------------------------------------------------------------
# Configuração personalizada do PHP
# ----------------------------------------------------------------------
# Arquivos presentes em conf.d são carregados automaticamente.
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-app.ini

# ----------------------------------------------------------------------
# Diretório de trabalho
# ----------------------------------------------------------------------
WORKDIR /var/www/html

# ----------------------------------------------------------------------
# Porta interna do PHP-FPM
# ----------------------------------------------------------------------
# EXPOSE documenta a porta, mas não a publica no Linux Mint.
EXPOSE 9000

# ----------------------------------------------------------------------
# Processo principal
# ----------------------------------------------------------------------
CMD ["php-fpm", "-F"]
