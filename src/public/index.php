<?php

declare(strict_types=1);

use App\App;
use App\Config;
use App\Controllers\HomeController;
use App\Controllers\InvoiceController;
use App\Exception\RouteNotFoundException;
use App\Router;
use App\View;

require dirname(__DIR__, 2) . '/vendor/autoload.php';

session_start();

define('STORAGE_PATH', dirname(__DIR__, 1) . '/storage');
define('VIEW_PATH', dirname(__DIR__, 1) . '/views/');

$router = new Router();
$router
    ->get('/', [HomeController::class, 'index'])
    ->get('/download', [HomeController::class, 'download'])
    ->post('/upload', [HomeController::class, 'upload'])
    ->get('/invoices', [InvoiceController::class, 'index'])
    ->get('/invoices/create', [InvoiceController::class, 'create'])
    ->post('/invoices/create', [InvoiceController::class, 'store']);

(new App(
    $router,
    ['uri' => $_SERVER['REQUEST_URI'], 'method' => $_SERVER['REQUEST_METHOD']],
    new Config(getenv()),
))->run();

