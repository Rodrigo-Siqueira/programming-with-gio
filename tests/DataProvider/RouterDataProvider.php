<?php

declare(strict_types=1);

namespace Tests\DataProvider;

class RouterDataProvider
{
    public static function routeNotFoundCases(): array
    {
        return [
            ['/users', 'post'],
            ['/users', 'get'],
            ['/users', 'put'],
            ['/invoices', 'post'],
        ];
    }
}
