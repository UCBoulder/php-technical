<?php

declare(strict_types=1);

require_once __DIR__ . '/support/Database.php';
require_once __DIR__ . '/support/Schema.php';
require_once __DIR__ . '/support/Args.php';

$command = $argv[1] ?? 'help';
$args = Args::parse($argv);

function requireSqlite(): void
{
    if (!extension_loaded('pdo_sqlite')) {
        fwrite(STDERR, "Missing PHP extension: pdo_sqlite\n");
        fwrite(STDERR, "Install it first (package names are commonly php-sqlite3 or php8.x-sqlite3).\n");
        exit(2);
    }
}

function printHelp(): void
{
    echo <<<'TXT'
Senior PHP Interview Lab

Commands:
  php lab.php setup:users [--users=10000] [--blob-bytes=768]
  php lab.php reset:users
  php lab.php inspect:users

  php lab.php setup:orders
  php lab.php reset:orders
  php lab.php inspect:orders

Exercises:
  php exercises/01_user_maintenance.php

  php exercises/02_order_processing.php

Typical flow:
  php lab.php setup:users
  php exercises/01_user_maintenance.php
  php lab.php reset:users

  php lab.php setup:orders
  php exercises/02_order_processing.php
  php lab.php inspect:orders
  php lab.php reset:orders
TXT;
    echo PHP_EOL;
}

if ($command === 'help') {
    printHelp();
    exit(0);
}

requireSqlite();

switch ($command) {
    case 'setup:users':
    case 'reset:users': {
        $pdo = Database::connect(__DIR__ . '/data/users.sqlite');
        Schema::createUsers($pdo);
        $count = Args::int($args, 'users', 10000);
        $blobBytes = Args::int($args, 'blob-bytes', 768);
        $blob = str_repeat('x', max(1, $blobBytes));

        echo "Seeding {$count} users...\n";
        $pdo->beginTransaction();
        $stmt = $pdo->prepare('INSERT INTO users(email, status, last_login_at, profile_blob) VALUES (?, ?, ?, ?)');
        for ($i = 1; $i <= $count; $i++) {
            // Roughly 80% are old enough to match the exercise query.
            $old = ($i % 5 !== 0);
            $date = $old ? '2024-01-01' : '2026-01-01';
            $stmt->execute(["user{$i}@example.test", 'active', $date, $blob]);
            if ($i % 10000 === 0) {
                echo "  {$i}\n";
            }
        }
        $pdo->commit();
        echo "User DB ready: data/users.sqlite\n";
        break;
    }

    case 'inspect:users': {
        $pdo = Database::connect(__DIR__ . '/data/users.sqlite');
        $rows = $pdo->query("SELECT status, COUNT(*) AS count FROM users GROUP BY status ORDER BY status")->fetchAll();
        foreach ($rows as $row) {
            printf("%-10s %d\n", $row['status'], $row['count']);
        }
        $eligible = $pdo->query("SELECT COUNT(*) FROM users WHERE status='active' AND last_login_at < '2025-08-13'")->fetchColumn();
        echo "Eligible active users remaining: {$eligible}\n";
        break;
    }

    case 'setup:orders':
    case 'reset:orders': {
        $pdo = Database::connect(__DIR__ . '/data/orders.sqlite');
        Schema::createOrders($pdo);
        $stmt = $pdo->prepare('INSERT INTO products(id, name, stock, price_cents) VALUES (?, ?, ?, ?)');
        foreach ([
            [1, 'Keyboard', 10, 5000],
            [2, 'Mouse', 10, 2500],
            [3, 'USB-C Cable', 10, 1200],
        ] as $row) {
            $stmt->execute($row);
        }
        echo "Order DB reset and seeded.\n";
        break;
    }

    case 'inspect:orders': {
        $pdo = Database::connect(__DIR__ . '/data/orders.sqlite');
        echo "\nPRODUCTS\n";
        foreach ($pdo->query('SELECT * FROM products ORDER BY id') as $row) {
            printf("  #%d %-15s stock=%d price=%d\n", $row['id'], $row['name'], $row['stock'], $row['price_cents']);
        }
        echo "\nORDERS\n";
        $rows = $pdo->query('SELECT * FROM orders ORDER BY id')->fetchAll();
        echo $rows ? '' : "  (none)\n";
        foreach ($rows as $row) {
            printf("  #%d status=%s total=%d\n", $row['id'], $row['status'], $row['total_cents']);
        }
        echo "\nORDER ITEMS\n";
        $rows = $pdo->query('SELECT * FROM order_items ORDER BY id')->fetchAll();
        echo $rows ? '' : "  (none)\n";
        foreach ($rows as $row) {
            printf("  #%d order=%d product=%d qty=%d\n", $row['id'], $row['order_id'], $row['product_id'], $row['quantity']);
        }
        echo "\nPAYMENTS\n";
        $rows = $pdo->query('SELECT * FROM payments ORDER BY id')->fetchAll();
        echo $rows ? '' : "  (none)\n";
        foreach ($rows as $row) {
            printf("  #%d order=%d amount=%d status=%s\n", $row['id'], $row['order_id'], $row['amount_cents'], $row['status']);
        }
        break;
    }

    case 'help':
    default:
        printHelp();
}
