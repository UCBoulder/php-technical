<?php

declare(strict_types=1);

// =============================================================================
// Setup
// =============================================================================

// Load dependencies.
require_once __DIR__ . '/../support/Database.php';

// Parse command-line options and connect to the exercise database.
$pdo = Database::connect(__DIR__ . '/../data/orders.sqlite');

// =============================================================================
// Exercise
// =============================================================================

// Define the products and quantities in the order.
$items = [
    ['product_id' => 1, 'quantity' => 2],
    ['product_id' => 2, 'quantity' => 1],
    ['product_id' => 3, 'quantity' => 3],
];

// Start processing the order
try {
    $pdo->exec("INSERT INTO orders(status, total_cents, created_at) VALUES ('pending', 0, datetime('now'))");
    $orderId = (int) $pdo->lastInsertId();

    $total = 0;
    foreach ($items as $item) {
        $productStmt = $pdo->prepare('SELECT price_cents, stock FROM products WHERE id = ?');
        $productStmt->execute([$item['product_id']]);
        $product = $productStmt->fetch();
    
        if (!$product) {
            throw new RuntimeException('Product not found');
        }
    
        if ((int) $product['stock'] < $item['quantity']) {
            throw new RuntimeException('Insufficient stock');
        }

        $lineTotal = (int) $product['price_cents'] * $item['quantity'];
        $total += $lineTotal;

        $insertItem = $pdo->prepare(<<<'SQL'
            INSERT INTO order_items(order_id, product_id, quantity, unit_price_cents)
            VALUES (?, ?, ?, ?)
        SQL);
        $insertItem->execute([$orderId, $item['product_id'], $item['quantity'], $product['price_cents']]);

        $newStock = (int) $product['stock'] - $item['quantity'];
        $updateStock = $pdo->prepare('UPDATE products SET stock = ? WHERE id = ?');
        $updateStock->execute([$newStock, $item['product_id']]);
    }

    $updateOrder = $pdo->prepare("UPDATE orders SET total_cents = ?, status = 'ready_for_payment' WHERE id = ?");
    $updateOrder->execute([$total, $orderId]);

    $payment = $pdo->prepare("INSERT INTO payments(order_id, amount_cents, status) VALUES (?, ?, 'pending')");
    $payment->execute([$orderId, $total]);

    echo "Order {$orderId} completed successfully.\n";
} catch (Throwable $e) {
    fwrite(STDERR, "FAILED: {$e->getMessage()}\n");
    fwrite(STDERR, "Inspect the DB now. Partial writes may remain.\n");
    exit(1);
}
