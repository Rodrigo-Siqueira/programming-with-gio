# PHP Docker Starter

Estação base reutilizável para desenvolvimento local de aplicações PHP com Docker, Nginx, PHP-FPM e Composer.

O objetivo deste projeto é fornecer um ambiente padronizado para iniciar novos projetos PHP sem precisar configurar novamente toda a infraestrutura local.

## Tecnologias

A estação utiliza:

- PHP 8.5 com PHP-FPM;
- Nginx 1.28;
- Composer 2;
- Docker;
- Docker Compose;
- Alpine Linux;
- Make, opcional.

## Recursos disponíveis

A configuração atual fornece:

- ambiente PHP executado em contêiner;
- servidor Nginx;
- PHP-FPM acessível somente pela rede interna;
- Composer disponível no contêiner PHP;
- autoload PSR-4;
- configuração PHP para desenvolvimento;
- OPcache;
- página pública de verificação;
- variáveis de ambiente;
- comandos simplificados pelo Makefile;
- validação dos requisitos da plataforma;
- auditoria de dependências pelo Composer;
- proteção básica de arquivos sensíveis.

## Extensões PHP

A imagem PHP contém:

- Intl;
- PDO;
- PDO MySQL;
- ZIP;
- Zend OPcache.

No PHP 8.5, o OPcache já faz parte do PHP e não precisa ser compilado separadamente.

## Requisitos

Antes de iniciar, instale:

- Docker;
- Docker Compose;
- Git;
- Make, opcional.

Verifique o Docker:

```bash
docker --version
```

Verifique o Docker Compose:

```bash
docker compose version
```

Verifique o Make, caso deseje utilizar os atalhos:

```bash
make --version
```

## Estrutura do projeto

```text
.
├── composer.json
├── composer.lock
├── compose.yaml
├── docker
│   ├── nginx
│   │   └── nginx.conf
│   └── php
│       ├── Dockerfile
│       └── php.ini
├── .dockerignore
├── .editorconfig
├── .env.example
├── .gitignore
├── Makefile
├── README.md
└── src
    └── public
        └── index.php
```

O diretório público da aplicação é:

```text
src/public
```

Somente o conteúdo desse diretório deve ser entregue diretamente pelo Nginx.

Arquivos como `.env`, `composer.json`, `compose.yaml` e as configurações do Docker ficam fora da raiz pública.

## Preparação inicial

Clone ou copie o projeto e acesse o diretório:

```bash
cd php-docker-starter
```

Crie o arquivo local de ambiente:

```bash
cp .env.example .env
```

O arquivo `.env` não deve ser versionado.

### Preparação com Make

Para preparar todo o ambiente:

```bash
make setup
```

Esse comando:

1. cria o `.env` quando necessário;
2. valida o Compose;
3. constrói as imagens;
4. inicia os serviços;
5. instala as dependências do Composer.

### Preparação sem Make

Execute:

```bash
cp .env.example .env
docker compose config --quiet
docker compose up -d --build
docker compose exec php composer install
```

## Acesso à aplicação

Com a configuração padrão, acesse:

```text
http://localhost:8080
```

A página inicial apresentará o estado do ambiente, incluindo:

- versão do PHP;
- ambiente da aplicação;
- modo de depuração;
- autoload do Composer;
- OPcache;
- extensões PHP necessárias.

A página não utiliza `phpinfo()`, evitando a exposição desnecessária de informações internas.

## Variáveis de ambiente

As variáveis disponíveis estão documentadas em:

```text
.env.example
```

Configuração padrão:

```dotenv
COMPOSE_PROJECT_NAME=php-docker-starter
APP_PORT=8080
APP_ENV=local
APP_DEBUG=true
```

### `COMPOSE_PROJECT_NAME`

Define o nome utilizado pelo Docker Compose para identificar os recursos do projeto.

### `APP_PORT`

Define a porta HTTP utilizada no computador.

Exemplo:

```dotenv
APP_PORT=8081
```

Nesse caso, a aplicação ficará disponível em:

```text
http://localhost:8081
```

Depois de alterar a porta, recrie o serviço:

```bash
docker compose up -d
```

### `APP_ENV`

Identifica o ambiente lógico da aplicação.

O valor padrão é:

```dotenv
APP_ENV=local
```

### `APP_DEBUG`

Identifica se os recursos de depuração da aplicação devem estar habilitados.

No desenvolvimento:

```dotenv
APP_DEBUG=true
```

Em produção, esse valor deverá ser:

```dotenv
APP_DEBUG=false
```

A variável `APP_DEBUG` não substitui as configurações de erros do `php.ini`.

## Comandos principais

### Exibir os comandos disponíveis

```bash
make help
```

### Iniciar os serviços

```bash
make up
```

Sem Make:

```bash
docker compose up -d
```

### Verificar os serviços

```bash
make ps
```

Sem Make:

```bash
docker compose ps
```

### Parar os serviços

```bash
make stop
```

Esse comando mantém os contêineres existentes.

### Parar e remover os contêineres

```bash
make down
```

Sem Make:

```bash
docker compose down
```

### Reiniciar os serviços

```bash
make restart
```

### Recriar os contêineres

Use este comando depois de alterar variáveis ou configurações do Compose:

```bash
make recreate
```

### Construir as imagens

```bash
make build
```

Sem Make:

```bash
docker compose build
```

### Reconstruir sem cache

```bash
make rebuild
```

Esse comando recompila as extensões PHP e pode demorar mais.

## Logs

### Todos os serviços

```bash
make logs
```

### PHP-FPM

```bash
make logs-php
```

### Nginx

```bash
make logs-nginx
```

Sem Make:

```bash
docker compose logs --follow --tail=100
```

Utilize `Ctrl+C` para encerrar o acompanhamento dos logs. Os contêineres continuarão em execução.

## PHP

### Exibir a versão

```bash
make php-version
```

Sem Make:

```bash
docker compose exec php php --version
```

### Exibir os arquivos de configuração

```bash
make php-config
```

Sem Make:

```bash
docker compose exec php php --ini
```

A configuração personalizada deverá aparecer como:

```text
/usr/local/etc/php/conf.d/99-app.ini
```

### Validar a sintaxe do arquivo inicial

```bash
docker compose exec php php -l src/public/index.php
```

Resultado esperado:

```text
No syntax errors detected in src/public/index.php
```

### Abrir o shell do contêiner

```bash
make shell
```

Sem Make:

```bash
docker compose exec php sh
```

A imagem Alpine utiliza `sh` em vez de `bash`.

Para sair:

```bash
exit
```

## Composer

Todos os comandos do Composer devem ser executados dentro do contêiner PHP. Isso garante o uso da versão correta do PHP e das extensões configuradas no Dockerfile.

### Exibir a versão

```bash
make composer-version
```

### Instalar dependências

```bash
make install
```

Sem Make:

```bash
docker compose exec php composer install
```

### Atualizar dependências

```bash
make update
```

O comando `update` modifica o `composer.lock`. Utilize-o de maneira intencional.

Para instalações normais, prefira:

```bash
make install
```

### Regenerar o autoload

```bash
make dump-autoload
```

### Validar o `composer.json`

```bash
make validate
```

### Verificar os requisitos da plataforma

```bash
make check-platform
```

Esse comando verifica:

- versão do PHP;
- extensão Intl;
- PDO;
- PDO MySQL;
- extensão ZIP.

### Executar todas as verificações

```bash
make check
```

### Auditar dependências

```bash
make audit
```

O comando verifica se as dependências instaladas possuem vulnerabilidades conhecidas registradas pelo Composer.

## Autoload PSR-4

As classes da aplicação utilizarão o namespace:

```text
App\
```

O namespace corresponde ao diretório:

```text
src/App/
```

Exemplo:

```php
<?php

declare(strict_types=1);

namespace App\Service;

final class ExampleService
{
}
```

O arquivo deverá ser salvo em:

```text
src/App/Service/ExampleService.php
```

Após adicionar ou reorganizar classes, regenere o autoload:

```bash
make dump-autoload
```

As classes de teste utilizarão futuramente o namespace:

```text
Tests\
```

correspondente ao diretório:

```text
tests/
```

## Nginx

### Validar a configuração

```bash
make nginx-test
```

Sem Make:

```bash
docker compose exec nginx nginx -t
```

Resultado esperado:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Front controller

Requisições que não correspondem a um arquivo ou diretório são encaminhadas para:

```text
src/public/index.php
```

Exemplo:

```bash
curl -i http://localhost:8080/rota-de-teste
```

A resposta deve ser processada pelo `index.php`.

## Segurança

A estação aplica as seguintes medidas básicas:

- PHP-FPM não publica a porta `9000` no computador;
- somente o Nginx publica uma porta HTTP;
- o código PHP é processado apenas quando o arquivo existe;
- a versão específica do Nginx não é divulgada;
- a versão do PHP não é enviada pelo cabeçalho `X-Powered-By`;
- inclusão remota de arquivos PHP está desabilitada;
- carregamento dinâmico de extensões está desabilitado;
- sessões utilizam modo estrito;
- identificadores de sessão são aceitos somente por cookies;
- cookies de sessão utilizam `HttpOnly`;
- cookies de sessão utilizam `SameSite=Lax`;
- arquivos ocultos são bloqueados pelo Nginx;
- arquivos de configuração e logs são bloqueados na raiz pública;
- plugins do Composer não são autorizados automaticamente;
- o `.env` é excluído do Git e do contexto de build;
- dependências podem ser verificadas com `composer audit`.

## Ambiente de desenvolvimento

O `php.ini` atual é destinado ao desenvolvimento local.

Por isso, utiliza:

```ini
display_errors = On
display_startup_errors = On
```

Isso ajuda a localizar falhas durante o desenvolvimento.

A configuração atual não deve ser utilizada diretamente em produção.

## Produção

Antes de implantar uma aplicação em produção, será necessário criar uma configuração específica.

Entre outras medidas, a configuração de produção deverá:

- desabilitar a exibição de erros;
- manter o registro de erros habilitado;
- utilizar HTTPS;
- habilitar `session.cookie_secure`;
- desabilitar o modo de depuração;
- utilizar imagens fixadas e reproduzíveis;
- instalar dependências sem pacotes de desenvolvimento;
- otimizar o autoload;
- evitar bind mounts do código;
- executar os processos com permissões mínimas;
- proteger diretórios graváveis;
- configurar políticas de backup;
- gerenciar segredos fora do repositório;
- adicionar monitoramento e tratamento de incidentes.

## Uploads

A estação ainda não possui um diretório público destinado a uploads.

Quando uploads forem implementados:

- nomes e extensões deverão ser validados;
- o tipo real do arquivo deverá ser verificado;
- nomes gerados pelo sistema deverão ser utilizados;
- arquivos executáveis deverão ser rejeitados;
- a execução de PHP deverá ser bloqueada no diretório;
- os arquivos deverão ficar fora da raiz pública sempre que possível.

## Banco de dados

Nenhum banco de dados faz parte desta primeira versão.

Uma aplicação derivada poderá adicionar posteriormente:

- PostgreSQL;
- MySQL;
- MariaDB;
- outro serviço compatível com o projeto.

O driver `pdo_mysql` já está disponível na imagem PHP para aplicações que utilizem MySQL ou MariaDB.

## Limpeza

Para remover contêineres, redes e volumes locais do projeto:

```bash
make clean
```

Esse comando não remove:

- arquivos do projeto;
- imagens Docker;
- `vendor`;
- `composer.lock`.

Para remover também as imagens geradas, utilize conscientemente os comandos apropriados do Docker.

## Solução de problemas

### Porta já está em uso

Altere no `.env`:

```dotenv
APP_PORT=8081
```

Depois recrie os serviços:

```bash
make recreate
```

### Erro 502 Bad Gateway

Verifique os serviços:

```bash
make ps
```

Consulte os logs:

```bash
make logs-php
make logs-nginx
```

Valide o Nginx:

```bash
make nginx-test
```

### Alteração no Dockerfile não foi aplicada

Reconstrua a imagem:

```bash
make build
```

Se necessário, ignore completamente o cache:

```bash
make rebuild
```

Depois recrie os contêineres:

```bash
make recreate
```

### Alteração no `php.ini` não foi aplicada

O arquivo é copiado durante a construção da imagem. Execute:

```bash
make build
make recreate
```

Confirme os arquivos carregados:

```bash
make php-config
```

### Alteração no `nginx.conf` não foi aplicada

A configuração é montada diretamente no contêiner.

Valide o arquivo:

```bash
make nginx-test
```

Depois reinicie o Nginx:

```bash
docker compose restart nginx
```

### Autoload ausente

Instale as dependências:

```bash
make install
```

Ou regenere o autoload:

```bash
make dump-autoload
```

### Erro `missing separator` no Makefile

As receitas do Makefile devem começar com uma tabulação real.

Verifique com:

```bash
cat -A Makefile
```

As receitas devem começar com:

```text
^I
```

## Verificação completa

Execute:

```bash
make config
make build
make up
make install
make check
make audit
make nginx-test
```

Depois acesse:

```text
http://localhost:8080
```

A página deverá indicar:

```text
Ambiente executado com sucesso
```

## Uso como base de novos projetos

Esta estação pode ser utilizada como template para novos projetos PHP.

Uma forma simples é copiar o repositório:

```bash
git clone URL_DO_REPOSITORIO novo-projeto
cd novo-projeto
rm -rf .git
git init
```

Depois:

```bash
cp .env.example .env
make setup
```

Ao criar um novo projeto, revise pelo menos:

- nome do projeto no `composer.json`;
- descrição do projeto;
- nome em `COMPOSE_PROJECT_NAME`;
- porta em `APP_PORT`;
- documentação;
- extensões PHP necessárias;
- dependências do Composer;
- licença;
- configurações específicas da aplicação.

## Escopo atual

Esta baseline fornece somente a infraestrutura inicial.

Ela não inclui:

- framework PHP;
- arquitetura MVC;
- banco de dados;
- autenticação;
- sistema de rotas;
- migrations;
- filas;
- Redis;
- envio de e-mails;
- PHPUnit;
- análise estática;
- configuração de produção;
- pipeline de integração contínua.

Esses recursos devem ser adicionados somente quando forem necessários para o projeto derivado.

## Licença

O projeto está marcado atualmente como proprietário no `composer.json`.

Antes de publicar a estação como template público, defina uma licença adequada e adicione o arquivo correspondente ao repositório.
