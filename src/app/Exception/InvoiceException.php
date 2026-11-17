<?php

declare(strict_types=1);

namespace App\Exception;

use Exception;

class InvoiceException extends Exception
{
    public static function missingBillingInfo(): static
    {
        return new static('Missing billing information.');
    }

    public static function invalidAmount(): static
    {
        return new static('Invalid invoice amount.');
    }
}
