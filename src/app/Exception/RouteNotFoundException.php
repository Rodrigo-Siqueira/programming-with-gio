<?php

declare(strict_types=1);

namespace App\Exception;

use Exception;

class RouteNotFoundException extends Exception
{
    protected $message = '404 not found.';
}
