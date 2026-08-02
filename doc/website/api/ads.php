<?php
/**
 * 熊猫相册 - 广告 API
 * 
 * 接口：GET /api/ads.php?position={position}
 * 返回：JSON 格式广告数据
 * 
 * 广告位标识：
 * - home_banner: 首页底部广告
 * - swipe_banner: 整理页底部广告
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Cache-Control: public, max-age=3600');

// 获取广告位标识
$position = $_GET['position'] ?? '';

// 广告配置 - 修改这里的广告内容
$ads = [
    'home_banner' => [
        'image' => '',  // 广告图片 URL，留空表示无广告
        'link' => '',   // 点击跳转链接
        'title' => ''   // 广告标题
    ],
    'swipe_banner' => [
        'image' => '',
        'link' => '',
        'title' => ''
    ]
];

// 返回对应广告位的广告，无广告时返回空
$response = $ads[$position] ?? ['image' => ''];

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>
