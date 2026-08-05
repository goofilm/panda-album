<?php
/**
 * 熊猫相册 - 匿名活跃统计接口
 *
 * 用法：
 *   上报：stats.php?action=report&device_id=xxx  （App启动时调用，device_id为随机匿名ID）
 *   汇总：stats.php?action=summary               （查看活跃数据）
 *
 * 仅记录随机设备ID，不采集任何个人信息。
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$dailyFile = __DIR__ . '/stats_daily.json';
$totalFile = __DIR__ . '/stats_total.json';

// 读取数据
$daily = [];
if (file_exists($dailyFile)) {
    $daily = json_decode(@file_get_contents($dailyFile), true) ?: [];
}
$total = [];
if (file_exists($totalFile)) {
    $total = json_decode(@file_get_contents($totalFile), true) ?: [];
}

$today = date('Y-m-d');
$action = $_REQUEST['action'] ?? 'report';

if ($action === 'report') {
    $deviceId = preg_replace('/[^A-Za-z0-9\-_]/', '', $_REQUEST['device_id'] ?? '');
    if ($deviceId === '') {
        echo json_encode(['ok' => false, 'error' => 'missing device_id']);
        exit;
    }

    // 当日活跃（去重）
    if (!isset($daily[$today])) {
        $daily[$today] = [];
    }
    if (!in_array($deviceId, $daily[$today], true)) {
        $daily[$today][] = $deviceId;
    }

    // 累计用户（去重）
    if (!in_array($deviceId, $total, true)) {
        $total[] = $deviceId;
    }

    // 每日数据只保留最近90天
    krsort($daily);
    $daily = array_slice($daily, 0, 90, true);

    @file_put_contents($dailyFile, json_encode($daily), LOCK_EX);
    @file_put_contents($totalFile, json_encode($total), LOCK_EX);

    echo json_encode([
        'ok' => true,
        'today_active' => count($daily[$today]),
        'total_users' => count($total),
    ]);
    exit;
}

if ($action === 'summary') {
    $dailyCounts = [];
    foreach ($daily as $date => $ids) {
        $dailyCounts[$date] = count($ids);
    }
    krsort($dailyCounts);

    echo json_encode([
        'ok' => true,
        'today_active' => $dailyCounts[$today] ?? 0,
        'last7' => array_slice($dailyCounts, 0, 7, true),
        'total_users' => count($total),
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode(['ok' => false, 'error' => 'unknown action']);
