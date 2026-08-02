# 熊猫相册部署指南

## 文件结构

```
lightforever.net/
├── index.html           # 官网首页
├── privacy_policy.html  # 隐私政策
├── nginx.conf           # Nginx 配置（参考）
├── api/
│   └── ads.php          # 广告 API
├── assets/
│   ├── mascot_panda.png # 应用图标
│   ├── wechat_qr.jpg    # 微信收款码
│   └── alipay_qr.jpg    # 支付宝收款码
└── download/
    └── PandaAlbum.apk   # APK 安装包
```

## 部署步骤

### 1. 上传文件

使用 WinSCP 或 FileZilla 连接服务器：
- 主机：lightforever.net
- 端口：22 (SFTP) 或 21 (FTP)
- 用户名/密码：你的服务器账号

上传到 `/var/www/lightforever.net/`

### 2. 配置 Nginx

SSH 登录服务器：

```bash
# 复制配置文件
sudo cp /var/www/lightforever.net/nginx.conf /etc/nginx/sites-available/lightforever.net

# 创建软链接
sudo ln -s /etc/nginx/sites-available/lightforever.net /etc/nginx/sites-enabled/

# 删除默认配置（如果有）
sudo rm /etc/nginx/sites-enabled/default

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl reload nginx
```

### 3. 设置权限

```bash
sudo chown -R www-data:www-data /var/www/lightforever.net
sudo chmod -R 755 /var/www/lightforever.net
```

### 4. 测试

访问以下地址检查：
- 首页：https://lightforever.net
- 下载：https://lightforever.net/download/PandaAlbum.apk
- 广告 API：https://lightforever.net/api/ads.php?position=home_banner
- 隐私政策：https://lightforever.net/privacy_policy.html

## 广告管理

编辑 `/var/www/lightforever.net/api/ads.php` 修改广告内容：

```php
$ads = [
    'home_banner' => [
        'image' => 'https://lightforever.net/ads/banner1.jpg',
        'link' => 'https://广告主网站.com',
        'title' => '广告标题'
    ],
    'swipe_banner' => [
        'image' => 'https://lightforever.net/ads/banner2.jpg',
        'link' => 'https://广告主网站.com',
        'title' => '广告标题'
    ]
];
```

## 更新 APK

1. 构建新版本 APK
2. 上传到 `/var/www/lightforever.net/download/PandaAlbum.apk`（覆盖旧文件）
3. 更新 `index.html` 中的版本号

## 常见问题

### APK 下载显示 404
检查 Nginx 配置中的 `location /download/` 块是否正确

### 广告 API 返回空
检查 `ads.php` 文件是否存在，以及广告图片 URL 是否正确

### 页面样式错乱
检查 `assets/` 目录是否完整上传
