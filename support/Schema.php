<?php

declare(strict_types=1);

final class Schema
{
    public static function createUsers(PDO $pdo): void
    {
        $pdo->exec('DROP TABLE IF EXISTS users');
        $pdo->exec(<<<'SQL'
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'active',
                last_login_at TEXT NOT NULL,
                profile_blob TEXT NOT NULL
            )
        SQL);
        $pdo->exec('CREATE INDEX idx_users_status_login ON users(status, last_login_at)');
    }

    public static function createOrders(PDO $pdo): void
    {
        $pdo->exec('DROP TABLE IF EXISTS payments');
        $pdo->exec('DROP TABLE IF EXISTS order_items');
        $pdo->exec('DROP TABLE IF EXISTS orders');
        $pdo->exec('DROP TABLE IF EXISTS products');

        $pdo->exec(<<<'SQL'
            CREATE TABLE products (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                stock INTEGER NOT NULL CHECK(stock >= 0),
                price_cents INTEGER NOT NULL
            )
        SQL);

        $pdo->exec(<<<'SQL'
            CREATE TABLE orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                status TEXT NOT NULL,
                total_cents INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
            )
        SQL);

        $pdo->exec(<<<'SQL'
            CREATE TABLE order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL REFERENCES orders(id),
                product_id INTEGER NOT NULL REFERENCES products(id),
                quantity INTEGER NOT NULL,
                unit_price_cents INTEGER NOT NULL
            )
        SQL);

        $pdo->exec(<<<'SQL'
            CREATE TABLE payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL REFERENCES orders(id),
                amount_cents INTEGER NOT NULL,
                status TEXT NOT NULL
            )
        SQL);
    }
}
