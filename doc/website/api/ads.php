<?php
/**
 * 熊猫相册 - 广告 API
 * 
 * 接口：GET /api/ads.php?position={position}
 * 返回：JSON 格式广告数据
 * 
 * 广告位标识：
 * - splash: 开屏广告
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
    'splash' => [
        'image' => 'https://lightforever.net/ads/banner_test.png',
        'link' => 'https://lightforever.net',
        'title' => '熊猫相册 - 你的照片整理助手'
    ],
    'home_banner' => [
        'image' => 'https://lightforever.net/ads/banner_test.png',
        'link' => 'https://lightforever.net',
        'title' => '熊猫相册 - 你的照片整理助手'
    ],
    'swipe_banner' => [
        'image' => 'https://lightforever.net/ads/banner_test.png',
        'link' => 'https://lightforever.net',
        'title' => '熊猫相册 - 你的照片整理助手'
    ]
];

// 返回对应广告位的广告，无广告时返回空
$response = $ads[$position] ?? ['image' => ''];

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>
