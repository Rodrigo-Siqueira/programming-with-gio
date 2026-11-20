<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Services\EmailService;
use App\Services\InvoiceService;
use App\Services\PaymentGatewayService;
use App\Services\SalesTaxService;
use PHPUnit\Framework\TestCase;

final class InvoiceServiceTest extends TestCase
{
    public function testItProcessesAnInvoice(): void
    {
        // Arrange
        // Esses serviços apenas substituem as dependências reais.
        $salesTaxServiceStub = $this->createStub(SalesTaxService::class);

        $emailServiceStub = $this->createStub(EmailService::class);

        // O gateway é um mock porque queremos verificar
        // que a cobrança realmente foi solicitada.
        $gatewayServiceMock = $this->createMock(
            PaymentGatewayService::class
        );

        $gatewayServiceMock
            ->expects(self::once())
            ->method('charge')
            ->willReturn(true);

        $invoiceService = new InvoiceService(
            $salesTaxServiceStub,
            $gatewayServiceMock,
            $emailServiceStub,
        );

        $customer = ['name' => 'Francisco'];
        $amount = 150;

        // Act
        $result = $invoiceService->process($customer, $amount);

        // Assert
        self::assertTrue($result);
    }
}
