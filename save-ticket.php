<?php
$secret = 'lotto-magic-2026';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit; }

$data = json_decode(file_get_contents('php://input'), true);
if (!$data || !isset($data['key']) || $data['key'] !== $secret) {
    http_response_code(403); exit;
}

$img = $data['image'];
$img = preg_replace('/^data:image\/png;base64,/', '', $img);
$img = base64_decode($img);
if (!$img) { http_response_code(400); exit; }

file_put_contents(__DIR__ . '/ticket.png', $img);
if (isset($data['total'])) {
    file_put_contents(__DIR__ . '/total.txt', (string)(int)$data['total']);
}
echo 'ok';
