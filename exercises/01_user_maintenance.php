<?php

declare(strict_types=1);

// =============================================================================
// Setup
// =============================================================================

// Load dependencies.
require_once __DIR__ . '/../support/Database.php';

// Connect to the exercise database.
$dbPath = __DIR__ . '/../data/users.sqlite';
$pdo = Database::connect($dbPath);

// =============================================================================
// Exercise
// =============================================================================

$users = $pdo->query(<<<'SQL'
    SELECT *
    FROM users
    WHERE status = 'active'
      AND last_login_at < '2025-08-13'
    ORDER BY id
SQL)->fetchAll();

foreach ($users as $user) {
    $stmt = $pdo->prepare("UPDATE users SET status = 'inactive' WHERE id = ?");
    $stmt->execute([$user['id']]);
}