# Senior Interview Lab

## Getting started

1. Open this repository in GitHub Codespaces.
2. Wait for the Codespace setup to finish.
3. Open a terminal in the Codespace.

## Introduction

This repository contains two independent PHP exercises:

1. **User maintenance**
2. **Order processing**

The lab is dependency-free and uses file-backed **SQLite** databases. You do not
need Docker, MySQL, PostgreSQL, Composer, or any third-party packages.

You can also list the available lab commands:

```bash
php lab.php help
```

## Candidate instructions

For each exercise:

1. Explain how the existing implementation works.
2. Identify anything you think should be improved.
3. Make appropriate changes while preserving intended behavior.
4. Explain your decisions and trade-offs.

You are encouraged to use your judgment about what to investigate and how far to refactor the
exercise. You may make code changes wherever appropriate.

Do not add external dependencies or require additional infrastructure.

The exercises are independent. Complete them in the order directed by your interviewer.

## Exercise 1 — User maintenance

Prepare a fresh user database:

```bash
php lab.php setup:users
```

Review and improve:

```text
code exercises/01_user_maintenance.php
```

Run the exercise:

```bash
php exercises/01_user_maintenance.php
```

Inspect the resulting user statuses:

```bash
php lab.php inspect:users
```

Re-run the reset command whenever you need to restore the original dataset:

```bash
php lab.php reset:users
```

## Exercise 2 — Order processing

Prepare a fresh order database:

```bash
php lab.php setup:orders
```

Review and improve:

```text
code exercises/02_order_processing.php
```

Run the exercise:

```bash
php exercises/02_order_processing.php
```

Inspect products, orders, order items, and payments:

```bash
php lab.php inspect:orders
```

Re-run the setup command whenever you need a clean database:

```bash
php lab.php reset:orders
```