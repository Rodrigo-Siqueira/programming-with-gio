<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| PHP Docker Starter
|--------------------------------------------------------------------------
|
| Página inicial de verificação do ambiente local.
|
| Esta página confirma:
|
| - funcionamento do Nginx;
| - comunicação com o PHP-FPM;
| - versão do PHP;
| - disponibilidade do autoload do Composer;
| - identificação do ambiente da aplicação;
| - disponibilidade das extensões necessárias.
|
| Não utilizamos phpinfo(), pois essa função expõe informações
| detalhadas sobre o servidor, caminhos, módulos e configurações.
|
*/

/*
|--------------------------------------------------------------------------
| Cabeçalhos da resposta
|--------------------------------------------------------------------------
|
| Define explicitamente que a resposta contém HTML codificado em UTF-8.
|
*/

header('Content-Type: text/html; charset=UTF-8');


/*
|--------------------------------------------------------------------------
| Autoload do Composer
|--------------------------------------------------------------------------
|
| O index.php está localizado em:
|
| /var/www/html/src/public/index.php
|
| O autoload do Composer está localizado em:
|
| /var/www/html/vendor/autoload.php
|
| Por isso, voltamos dois diretórios a partir de __DIR__.
|
*/

$autoloadPath = dirname(__DIR__, 2) . '/vendor/autoload.php';

$autoloadAvailable = is_file($autoloadPath);

if ($autoloadAvailable) {
    require $autoloadPath;
}


/*
|--------------------------------------------------------------------------
| Informações não sensíveis do ambiente
|--------------------------------------------------------------------------
|
| Exibimos apenas informações necessárias para verificar a estação.
| Não mostramos caminhos internos, variáveis completas, configurações
| do servidor ou outras informações potencialmente sensíveis.
|
*/

$appEnvironment = getenv('APP_ENV');

if ($appEnvironment === false || $appEnvironment === '') {
    $appEnvironment = 'não definido';
}

$appDebug = getenv('APP_DEBUG');

$debugEnabled = filter_var(
    $appDebug,
    FILTER_VALIDATE_BOOLEAN
);

$requiredExtensions = [
    'intl',
    'PDO',
    'pdo_mysql',
    'zip',
];

$extensionStatus = [];

foreach ($requiredExtensions as $extension) {
    $extensionStatus[$extension] = extension_loaded($extension);
}

$opcacheAvailable = extension_loaded('Zend OPcache');

$allRequirementsAvailable =
    $autoloadAvailable
    && $opcacheAvailable
    && !in_array(false, $extensionStatus, true);


/*
|--------------------------------------------------------------------------
| Função de escape
|--------------------------------------------------------------------------
|
| Todo conteúdo dinâmico exibido no HTML passa por esta função.
|
| Isso evita que caracteres especiais sejam interpretados como HTML.
| Essa proteção será importante quando valores puderem vir de fontes
| externas ou de configurações alteradas pelo usuário.
|
*/

function escape(string $value): string
{
    return htmlspecialchars(
        $value,
        ENT_QUOTES | ENT_SUBSTITUTE,
        'UTF-8'
    );
}

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1"
    >

    <title>PHP Docker Starter</title>

    <style>
        :root {
            color-scheme: dark;
            font-family:
                Inter,
                ui-sans-serif,
                system-ui,
                -apple-system,
                BlinkMacSystemFont,
                "Segoe UI",
                sans-serif;
        }

        * {
            box-sizing: border-box;
        }

        body {
            display: grid;
            min-height: 100vh;
            margin: 0;
            padding: 24px;
            place-items: center;
            background:
                radial-gradient(
                    circle at top,
                    #1e3a5f 0,
                    #111827 45%,
                    #090f1a 100%
                );
            color: #e5e7eb;
        }

        main {
            width: min(100%, 760px);
            padding: 32px;
            border: 1px solid #334155;
            border-radius: 18px;
            background: rgb(15 23 42 / 92%);
            box-shadow: 0 24px 60px rgb(0 0 0 / 35%);
        }

        h1 {
            margin: 0;
            color: #93c5fd;
            font-size: clamp(2rem, 6vw, 3rem);
            line-height: 1.1;
        }

        .subtitle {
            margin: 12px 0 28px;
            color: #94a3b8;
            line-height: 1.6;
        }

        .summary {
            display: flex;
            gap: 12px;
            align-items: center;
            margin-bottom: 28px;
            padding: 16px;
            border: 1px solid #334155;
            border-radius: 12px;
            background: #111827;
        }

        .summary-indicator {
            flex: 0 0 auto;
            width: 14px;
            height: 14px;
            border-radius: 50%;
        }

        .summary-indicator.success {
            background: #4ade80;
            box-shadow: 0 0 16px rgb(74 222 128 / 65%);
        }

        .summary-indicator.warning {
            background: #fbbf24;
            box-shadow: 0 0 16px rgb(251 191 36 / 65%);
        }

        .summary strong {
            display: block;
            color: #f8fafc;
        }

        .summary span {
            display: block;
            margin-top: 4px;
            color: #94a3b8;
            font-size: 0.95rem;
        }

        dl {
            display: grid;
            grid-template-columns: minmax(150px, 1fr) 2fr;
            gap: 0;
            overflow: hidden;
            margin: 0;
            border: 1px solid #334155;
            border-radius: 12px;
        }

        dt,
        dd {
            min-width: 0;
            margin: 0;
            padding: 14px 16px;
            border-bottom: 1px solid #334155;
        }

        dt {
            background: #111827;
            color: #cbd5e1;
            font-weight: 600;
        }

        dd {
            overflow-wrap: anywhere;
            background: #172033;
        }

        dt:last-of-type,
        dd:last-of-type {
            border-bottom: 0;
        }

        code {
            padding: 3px 7px;
            border: 1px solid #334155;
            border-radius: 6px;
            background: #0f172a;
            color: #bfdbfe;
            font-family:
                "Cascadia Code",
                "Fira Code",
                ui-monospace,
                monospace;
        }

        .status {
            font-weight: 700;
        }

        .status.success {
            color: #4ade80;
        }

        .status.warning {
            color: #fbbf24;
        }

        footer {
            margin-top: 24px;
            color: #64748b;
            font-size: 0.9rem;
            text-align: center;
        }

        @media (max-width: 600px) {
            main {
                padding: 22px;
            }

            dl {
                grid-template-columns: 1fr;
            }

            dt,
            dd {
                border-bottom: 1px solid #334155;
            }

            dd:last-of-type {
                border-bottom: 0;
            }
        }
    </style>
</head>
<body>
    <main>
        <h1>PHP Docker Starter</h1>

        <p class="subtitle">
            Estação base para desenvolvimento de aplicações PHP
            com Nginx, PHP-FPM, Composer e Docker.
        </p>

        <section class="summary">
            <span
                class="summary-indicator <?= $allRequirementsAvailable
                    ? 'success'
                    : 'warning' ?>"
                aria-hidden="true"
            ></span>

            <div>
                <strong>
                    <?= $allRequirementsAvailable
                        ? 'Ambiente executado com sucesso'
                        : 'Ambiente executado com pendências' ?>
                </strong>

                <span>
                    Nginx e PHP-FPM estão se comunicando corretamente.
                </span>
            </div>
        </section>

        <dl>
            <dt>PHP</dt>
            <dd>
                <code><?= escape(PHP_VERSION) ?></code>
            </dd>

            <dt>Ambiente</dt>
            <dd>
                <code><?= escape($appEnvironment) ?></code>
            </dd>

            <dt>Depuração</dt>
            <dd>
                <span
                    class="status <?= $debugEnabled
                        ? 'warning'
                        : 'success' ?>"
                >
                    <?= $debugEnabled ? 'habilitada' : 'desabilitada' ?>
                </span>
            </dd>

            <dt>Composer</dt>
            <dd>
                <span
                    class="status <?= $autoloadAvailable
                        ? 'success'
                        : 'warning' ?>"
                >
                    <?= $autoloadAvailable
                        ? 'autoload disponível'
                        : 'autoload ausente' ?>
                </span>
            </dd>

            <dt>OPcache</dt>
            <dd>
                <span
                    class="status <?= $opcacheAvailable
                        ? 'success'
                        : 'warning' ?>"
                >
                    <?= $opcacheAvailable
                        ? 'disponível'
                        : 'ausente' ?>
                </span>
            </dd>

            <?php foreach ($extensionStatus as $extension => $loaded): ?>
                <dt>Extensão <?= escape($extension) ?></dt>

                <dd>
                    <span
                        class="status <?= $loaded
                            ? 'success'
                            : 'warning' ?>"
                    >
                        <?= $loaded ? 'disponível' : 'ausente' ?>
                    </span>
                </dd>
            <?php endforeach; ?>
        </dl>

        <footer>
            Página de verificação destinada ao desenvolvimento local.
        </footer>
    </main>
</body>
</html>
