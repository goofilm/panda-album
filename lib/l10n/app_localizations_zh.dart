// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '熊猫相册';

  @override
  String get photoOrganize => '照片整理';

  @override
  String get videoOrganize => '视频整理';

  @override
  String get photo => '照片';

  @override
  String get video => '视频';

  @override
  String get category => '分类';

  @override
  String get kept => '已保留';

  @override
  String get private => '私密';

  @override
  String get recycleBin => '回收站';

  @override
  String get startOrganize => '开始整理';

  @override
  String get swipeHint => '左滑保留 · 右滑删除 · 下滑分类';

  @override
  String get search => '搜索';

  @override
  String get settings => 'settings';

  @override
  String get lock => '锁定';

  @override
  String get select => '选择';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get delete => '删除';

  @override
  String get restore => '恢复';

  @override
  String get moveToRecycleBin => '移到回收站';

  @override
  String confirmMoveToRecycleBin(Object count) {
    return '确定将选中的 $count 张移到回收站？';
  }

  @override
  String get permanentlyDelete => '永久删除';

  @override
  String get emptyRecycleBin => '清空回收站';

  @override
  String get createCategory => '新建分类';

  @override
  String get categoryName => '分类名称';

  @override
  String get selectIcon => '选择图标';

  @override
  String get selectColor => '选择颜色';

  @override
  String get create => '创建';

  @override
  String get privateAlbum => '私密相册';

  @override
  String get createPrivateAlbum => '创建私密相册';

  @override
  String get createPrivateVideoAlbum => '创建私密视频相册';

  @override
  String get albumName => '相册名称';

  @override
  String get photoAlbum => '照片';

  @override
  String get videoAlbum => '视频';

  @override
  String get enterPin => '请输入PIN码';

  @override
  String get wrongPin => 'PIN码错误';

  @override
  String get setPin => '设置PIN码';

  @override
  String get changePin => '修改PIN码';

  @override
  String get closePin => '关闭PIN保护';

  @override
  String get membership => '会员';

  @override
  String get membershipCenter => '会员中心';

  @override
  String get openMembership => '开通会员';

  @override
  String get premiumMember => '尊贵的会员';

  @override
  String get pandaVip => '熊猫相册 VIP';

  @override
  String get thankSupport => '感谢您的支持';

  @override
  String get unlockAll => '解锁全部功能，畅享完整体验';

  @override
  String get premiumBenefits => '会员专享权益';

  @override
  String get unlimitedCategory => '无限分类';

  @override
  String get unlimitedCategoryDesc => '自由创建任意数量分类';

  @override
  String get unlimitedPrivate => '无限私密';

  @override
  String get unlimitedPrivateDesc => '私密相册不再受限';

  @override
  String get permanentRecycle => '永久回收站';

  @override
  String get permanentRecycleDesc => '回收站照片不会被自动清理';

  @override
  String get prioritySupport => '优先客服';

  @override
  String get prioritySupportDesc => '专属客服快速响应';

  @override
  String get yearlyPlan => '年度会员';

  @override
  String get monthlyPlan => '月度会员';

  @override
  String get yearlyPrice => '¥98';

  @override
  String get monthlyPrice => '¥12';

  @override
  String get perYear => '/年';

  @override
  String get perMonth => '/月';

  @override
  String get savePercent => '省 38%';

  @override
  String get autoRenew => '自动续费，随时取消';

  @override
  String get subscribeNow => '立即开通';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get subscriptionNote =>
      '订阅说明：\n• 订阅到期后自动续费，可在应用商店随时取消\n• 取消后当前周期内仍可使用会员功能\n• 到期后未续费将恢复免费版\n• 所有价格均含税';

  @override
  String get freeLimit => '免费版限制';

  @override
  String freeCategoryLimit(Object limit) {
    return '免费版最多创建 $limit 个分类';
  }

  @override
  String freePrivateLimit(Object limit) {
    return '免费版最多创建 $limit 个私密相册';
  }

  @override
  String get upgradeToPremium => '开通会员可创建无限分类';

  @override
  String get upgradeToPremiumPrivate => '开通会员可创建无限私密相册';

  @override
  String get permanentlyKept => '永久保留';

  @override
  String daysRemaining(Object days) {
    return '剩余$days天';
  }

  @override
  String get expired => '已过期';

  @override
  String get scanPhotos => '开始扫描';

  @override
  String get rescan => '重新扫描';

  @override
  String get scanning => '正在扫描';

  @override
  String get analyzing => '正在分析';

  @override
  String get scanComplete => '扫描完成';

  @override
  String get noDuplicates => '没有发现重复照片';

  @override
  String foundDuplicates(Object count) {
    return '发现 $count 组重复照片';
  }

  @override
  String get keep => '保留';

  @override
  String get allPhotosOrganized => '所有照片已处理完成';

  @override
  String get noTagData => '暂无标签数据';

  @override
  String get noFaceData => '暂无人物分组';

  @override
  String get tapToCreate => '点击\"开始检测\"自动识别人脸并分组';

  @override
  String get detecting => '检测中';

  @override
  String get startDetect => '开始检测';

  @override
  String get redetect => '重新检测';

  @override
  String photosWithFaces(Object count) {
    return '$count 张照片含有人脸';
  }

  @override
  String personGroups(Object count) {
    return '$count 个人物分组';
  }

  @override
  String get untitled => '未命名';

  @override
  String get createTime => '创建时间';

  @override
  String get renameGroup => '重命名分组';

  @override
  String get enterName => '输入人物名称';

  @override
  String get noPhotos => '暂无照片';

  @override
  String organizedProgress(Object organized, Object total) {
    return '已整理 $organized 张 / 共 $total 张';
  }

  @override
  String organizedVideoProgress(Object organized, Object total) {
    return '已整理 $organized 个 / 共 $total 个';
  }

  @override
  String get scanningEllipsis => '正在扫描...';

  @override
  String expireDate(Object date) {
    return '到期时间: $date';
  }

  @override
  String purchaseSuccess(Object level) {
    return '恭喜！$level会员开通成功';
  }

  @override
  String get purchaseFailed => '购买失败，请稍后重试';

  @override
  String get restoreSuccess => '恢复购买成功';

  @override
  String get restoreFailed => '未找到可恢复的购买记录';

  @override
  String get yearly => '年度';

  @override
  String get monthly => '月度';

  @override
  String get myCategories => '我的分类';

  @override
  String photoCategoryCount(Object count, Object organized) {
    return '照片分类 $count 个 · 已收纳 $organized 张';
  }

  @override
  String videoCategoryCount(Object count) {
    return '视频分类 $count 个';
  }

  @override
  String photoCategoryTab(Object count) {
    return '照片分类 ($count)';
  }

  @override
  String videoCategoryTab(Object count) {
    return '视频分类 ($count)';
  }

  @override
  String get privateVideoAlbum => '私密视频相册';

  @override
  String get privatePhotoAlbum => '私密照片相册';

  @override
  String privateProtected(Object count, Object type) {
    return '$count 个$type已保护';
  }

  @override
  String get enterPrivateSpace => '点击进入私密空间';

  @override
  String get rename => '重命名';

  @override
  String get mergeTo => '合并到...';

  @override
  String get editCategory => '编辑分类';

  @override
  String get iconLabel => '图标';

  @override
  String get colorLabel => '颜色';

  @override
  String get save => '保存';

  @override
  String get deleteCategory => '删除分类';

  @override
  String confirmDeleteCategory(Object name) {
    return '确定删除「$name」？';
  }

  @override
  String confirmDeleteCategoryWithPhotos(Object count, Object name) {
    return '确定删除「$name」？\n该分类下 $count 张照片将回到待整理状态，需要重新分类。';
  }

  @override
  String mergedTo(Object name) {
    return '已合并到「$name」';
  }

  @override
  String itemsCount(Object count) {
    return '$count 个';
  }

  @override
  String get recycleBinEmpty => '回收站是空的';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String dateMonthDay(Object day, Object month) {
    return '$month月$day日';
  }

  @override
  String groupItemCount(Object count, Object label) {
    return '$label · $count 张';
  }

  @override
  String get confirmPermanentDeletePhoto => '确定永久删除此照片？此操作不可恢复。';

  @override
  String get restoreAll => '全部恢复';

  @override
  String get clearAll => '清空所有';

  @override
  String get selectAllText => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String confirmPermanentDeleteSelected(Object count) {
    return '确定永久删除选中的 $count 张照片？';
  }

  @override
  String get confirmClearRecycleBin => '确定清空回收站？此操作不可恢复。';

  @override
  String get clear => '清空';
}
