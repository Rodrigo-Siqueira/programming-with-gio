# Programming with Gio — PHP: The Right Way

Projeto de estudo desenvolvido durante a segunda parte do curso **PHP: The Right Way**, do Programming with Gio.

> **Status:** Parte 2 concluída.

## Sobre a aplicação

A aplicação é uma base PHP estruturada com front controller, roteamento, controllers, views e models. O projeto implementa o fluxo inicial de usuários e invoices utilizando MySQL.

## Funcionalidades

- roteamento para requisições `GET` e `POST`;
- controllers para a página inicial e invoices;
- renderização de views com parâmetros;
- conexão com MySQL usando PDO;
- criação de usuários;
- criação e consulta de invoices;
- relacionamento entre usuários e invoices;
- transação para o cadastro de usuário e invoice;
- resposta para páginas não encontradas;
- download e upload de arquivos no armazenamento local.

## Rotas disponíveis

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/` | Exibe a página inicial e uma invoice de exemplo |
| `GET` | `/download` | Faz o download de um arquivo PDF |
| `POST` | `/upload` | Envia um arquivo para o armazenamento local |
| `GET` | `/invoices` | Exibe a página de invoices |
| `GET` | `/invoices/create` | Exibe o formulário de criação |
| `POST` | `/invoices/create` | Recebe os dados de uma invoice |

## Estrutura da aplicação

```text
src/
├── app/
│   ├── Controllers/  # Controllers da aplicação
│   ├── Exception/    # Exceções personalizadas
│   ├── Model/        # Models de usuários, invoices e cadastro
│   ├── App.php       # Inicialização e execução da aplicação
│   ├── Config.php    # Configurações do ambiente
│   ├── DB.php        # Conexão com o banco de dados
│   ├── Model.php     # Classe base dos models
│   ├── Router.php    # Registro e resolução das rotas
│   └── View.php      # Renderização das views
├── public/
│   └── index.php     # Front controller
├── storage/          # Arquivos armazenados pela aplicação
└── views/            # Templates HTML/PHP
```

O namespace das classes da aplicação é `App\`, com autoload PSR-4 configurado para o diretório `src/app/`.

## Banco de dados

A aplicação utiliza MySQL e espera as seguintes tabelas:

- `users`: usuários cadastrados;
- `invoices`: invoices vinculadas aos usuários.

As configurações de conexão são obtidas pelas variáveis de ambiente `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` e `DB_DATABASE`.

## Executar o projeto

Com o ambiente configurado, instale as dependências e inicie a aplicação:

```bash
composer install
```

A aplicação ficará disponível na URL configurada pelo ambiente local.

## Escopo atual

A Parte 2 concentra-se na estrutura inicial da aplicação, no roteamento, na integração com o banco de dados e no fluxo básico de invoices.

Ainda não fazem parte deste escopo:

- autenticação e autorização;
- validação completa dos formulários;
- migrations e seeders;
- listagem completa de invoices;
- testes automatizados;
- configuração para produção.
