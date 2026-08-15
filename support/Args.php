<?php

declare(strict_types=1);

final class Args
{
    /** @return array<string, string|bool> */
    public static function parse(array $argv): array
    {
        $out = [];
        foreach (array_slice($argv, 1) as $arg) {
            if (!str_starts_with($arg, '--')) {
                continue;
            }
            $arg = substr($arg, 2);
            if (str_contains($arg, '=')) {
                [$key, $value] = explode('=', $arg, 2);
                $out[$key] = $value;
            } else {
                $out[$arg] = true;
            }
        }
        return $out;
    }

    public static function int(array $args, string $key, int $default): int
    {
        return isset($args[$key]) ? (int) $args[$key] : $default;
    }

    public static function string(array $args, string $key, string $default): string
    {
        return isset($args[$key]) ? (string) $args[$key] : $default;
    }
}
