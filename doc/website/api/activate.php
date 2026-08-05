<?php
/**
 * 熊猫相册 - 激活码联网校验接口
 *
 * 用法：
 *   激活：activate.php?action=activate&code=PANDA-XXXXXXXX-X&device_id=xxx
 *   汇总：activate.php?action=summary   （查看所有激活记录）
 *
 * 规则：
 *   - 每个激活码最多绑定 2 台设备
 *   - 超出时自动挤掉最早激活的设备（换机免维护）
 *   - 同一设备重复激活直接放行
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$recordFile = __DIR__ . '/activations.json';

// 与 App 端保持一致的密钥和校验算法
$secret = 'PandaAlbum2025Secret';

function generateCheckDigit($randomPart, $type, $secret) {
    $combined = $randomPart . $secret . $type;
    $hash = 0;
    $len = strlen($combined);
    for ($i = 0; $i < $len; $i++) {
        $hash = ($hash * 31 + ord($combined[$i])) & 0xFFFFFFFF;
    }
    return strtoupper(dechex($hash & 0xF));
}

function validateCode($code, $secret) {
    $code = strtoupper(trim($code));
    if (!preg_match('/^PANDA-[A-Z2-9]{8}-[0-9A-F]$/', $code)) {
        return 'invalid';
    }
    $parts = explode('-', $code);
    $randomPart = $parts[1];
    $checkDigit = $parts[2];
    if ($checkDigit === generateCheckDigit($randomPart, 'monthly', $secret)) return 'valid_monthly';
    if ($checkDigit === generateCheckDigit($randomPart, 'yearly', $secret)) return 'valid_yearly';
    return 'invalid';
}

// 读取激活记录
$records = [];
if (file_exists($recordFile)) {
    $records = json_decode(@file_get_contents($recordFile), true) ?: [];
}

$action = $_REQUEST['action'] ?? 'activate';

if ($action === 'summary') {
    $totalCodes = count($records);
    $totalDevices = 0;
    foreach ($records as $devices) {
        $totalDevices += count($devices);
    }
    echo json_encode([
        'ok' => true,
        'total_codes' => $totalCodes,
        'total_devices' => $totalDevices,
        'records' => $records,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// ===== 激活请求 =====
$code = strtoupper(trim($_REQUEST['code'] ?? ''));
$deviceId = preg_replace('/[^A-Za-z0-9\-_]/', '', $_REQUEST['device_id'] ?? '');

if ($code === '' || strlen($deviceId) < 8) {
    echo json_encode(['ok' => false, 'reason' => 'bad_request']);
    exit;
}

$valid = validateCode($code, $secret);
if ($valid === 'invalid') {
    echo json_encode(['ok' => false, 'reason' => 'invalid_code']);
    exit;
}

$type = ($valid === 'valid_yearly') ? 'yearly' : 'monthly';
$devices = $records[$code] ?? [];

// 已在本设备激活过 → 直接放行
foreach ($devices as $d) {
    if ($d['device_id'] === $deviceId) {
        echo json_encode(['ok' => true, 'type' => $type, 'reused' => true]);
        exit;
    }
}

// 超过 2 台设备 → 挤掉最早激活的
if (count($devices) >= 2) {
    usort($devices, function ($a, $b) {
        return $a['time'] <=> $b['time'];
    });
    array_shift($devices);
}

$devices[] = [
    'device_id' => $deviceId,
    'time' => time(),
];
$records[$code] = $devices;

file_put_contents($recordFile, json_encode($records, JSON_UNESCAPED_UNICODE), LOCK_EX);

echo json_encode(['ok' => true, 'type' => $type, 'reused' => false]);
