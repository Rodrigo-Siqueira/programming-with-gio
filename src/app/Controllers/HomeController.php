<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Model\Invoice;
use App\Model\SignUp;
use App\Model\User;
use App\View;
class HomeController
{
    public function index(): View
    {
        $email = 'luffy@lab.com';
        $name = 'luffy Doe';
        $amount = 34;

        $userModel = new User();
        $invoiceModel = new Invoice();

        $invoiceId = (new SignUp($userModel, $invoiceModel))->register(
            ['name' => $name, 'email' => $email],
            ['amount' => $amount],
        );

        return View::make('index', [
            'invoice' => $invoiceModel->find($invoiceId),
        ]);
    }

    public function download() : void {
        header('Content-Type: Application/pdf');
        header('Content-Disposition: Attachment;filename="myfile.pdf"');

        readfile(STORAGE_PATH . '/Fechamento_11-2026.pdf');
    }

    public function upload(): void
    {
        $filePath = STORAGE_PATH . '/' . $_FILES['recipt']['name'];

        move_uploaded_file(
            $_FILES['recipt']['tmp_name'],
            $filePath
        );

        header('Location: /');
        exit;
    }
}
