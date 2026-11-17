<pre>
    <?php var_dump($invoice); ?>
</pre>

<?php if (!empty($invoice)): ?>
    <h2>Invoice encontrada!</h2>

    <p>ID: <?= $invoice['id'] ?></p>
    <p>Valor: <?= $invoice['amount'] ?></p>
    <p>Nome: <?= htmlspecialchars($invoice['full_name']) ?></p>
<?php else: ?>
    <p>Nenhuma invoice encontrada.</p>
<?php endif; ?>
