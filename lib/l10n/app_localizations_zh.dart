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
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get share => '分享';

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
  String get unlockAll => '免广告，畅享完整体验';

  @override
  String get premiumBenefits => '会员专享权益';

  @override
  String get adFreeBenefit => '全程免广告';

  @override
  String get adFreeBenefitDesc => '免开屏、Banner等所有广告';

  @override
  String get splashAdBenefit => '免开屏广告';

  @override
  String get splashAdBenefitDesc => '打开App直达首页，无需等待';

  @override
  String get prioritySupport => '优先客服';

  @override
  String get prioritySupportDesc => '专属客服快速响应';

  @override
  String get yearlyPlan => '年度会员';

  @override
  String get monthlyPlan => '月度会员';

  @override
  String get yearlyPrice => '¥15';

  @override
  String get monthlyPrice => '¥3';

  @override
  String get perYear => '/年';

  @override
  String get perMonth => '/月';

  @override
  String get savePercent => '省 58%';

  @override
  String get autoRenew => '到期后不自动续费';

  @override
  String get subscribeNow => '立即开通';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get subscriptionNote =>
      '开通说明：\n• 点击开通进入官方微店购买\n• 付款后自动发放激活码\n• 在下方输入激活码即可免广告\n• 到期后自动恢复免费版';

  @override
  String skipAd(Object seconds) {
    return '跳过 ${seconds}s';
  }

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

  @override
  String get createVideoCategory => '创建视频分类';

  @override
  String get createCategoryTitle => '创建分类';

  @override
  String get categoryNameHint => '例如：宝宝、宠物、汽车';

  @override
  String get saveCategory => '保存分类';

  @override
  String get enterCategoryName => '请输入分类名称';

  @override
  String get tapHint => '点击查看 · 长按操作 · 全屏上下滑动切换';

  @override
  String currentName(Object name) {
    return '当前: $name';
  }

  @override
  String get changeCategory => '修改分类';

  @override
  String get moveToPrivate => '移入私密相册';

  @override
  String get removeFromCategory => '移出分类';

  @override
  String get remove => '移出';

  @override
  String selectedCount(Object count) {
    return '已选 $count 项';
  }

  @override
  String get enterPhotoName => '输入照片/视频名称';

  @override
  String get noOtherCategories => '没有其他可用的分类，请先创建';

  @override
  String get moveToCategory => '移动到分类';

  @override
  String photoCount(Object count) {
    return '$count 张';
  }

  @override
  String movedTo(Object name) {
    return '已移动到「$name」';
  }

  @override
  String get createPrivatePhotoAlbumFirst => '请先创建私密照片相册';

  @override
  String get createPrivateVideoAlbumFirst => '请先创建私密视频相册';

  @override
  String get selectPrivateAlbum => '选择私密相册';

  @override
  String albumProtected(Object count) {
    return '$count 个已保护';
  }

  @override
  String movedToPrivateAlbum(Object name) {
    return '已移入「$name」私密相册';
  }

  @override
  String confirmRemoveFromCategory(Object count) {
    return '确定将选中的 $count 张移出当前分类？\n移出后需要重新整理。';
  }

  @override
  String confirmMoveToRecycleBinDetail(Object count) {
    return '确定将选中的 $count 张移到回收站？\n30天后将自动永久删除。';
  }

  @override
  String get preview => '预览';

  @override
  String get videoLoadFailed => '视频加载失败';

  @override
  String get defaultCatWork => '工作';

  @override
  String get defaultCatLife => '生活';

  @override
  String get defaultCatTravel => '旅行';

  @override
  String get defaultCatFood => '美食';

  @override
  String get defaultCatScreenshot => '截图';

  @override
  String get defaultCatPortrait => '人像';

  @override
  String get defaultCatVlog => 'Vlog';

  @override
  String get defaultCatTutorial => '教程';

  @override
  String get defaultCatPet => '宠物';

  @override
  String get defaultCatSports => '运动';

  @override
  String get defaultCatMusic => '音乐';

  @override
  String get defaultCatScreenRecord => '录屏';

  @override
  String get activateWithCode => '使用激活码';

  @override
  String get activateCodeHint => '请输入您购买的激活码，格式：PANDA-XXXXXXXX-X';

  @override
  String get activateSuccess => '激活成功！会员已开通';

  @override
  String get activateAlreadyUsed => '该激活码已被使用';

  @override
  String get activateInvalid => '激活码无效，请检查后重试';

  @override
  String get scanToPurchase => '购买会员';

  @override
  String get purchaseQRHint => '点击开通按钮前往官方微店购买\n月卡 ¥3 · 年卡 ¥15';

  @override
  String get purchaseQRNote => '付款后自动发放激活码';

  @override
  String get membershipExpired => '会员已过期';

  @override
  String get categoryPremiumRequired => '分类整理功能需要会员，请续费后继续使用';

  @override
  String get screenshotCleanup => '截图清理';

  @override
  String screenshotTotal(Object count) {
    return '共 $count 张截图';
  }

  @override
  String get screenshotNotFound => '没有找到截图';

  @override
  String screenshotSelected(Object count) {
    return '已选 $count 项';
  }

  @override
  String get screenshotSelectAll => '全选';

  @override
  String get screenshotDeselectAll => '取消全选';

  @override
  String screenshotConfirmDelete(Object count) {
    return '确定要删除选中的 $count 张截图吗？';
  }

  @override
  String screenshotDeleted(Object count) {
    return '已删除 $count 张截图';
  }

  @override
  String get screenshotCleanDesc => '清理不需要的截图，释放存储空间';

  @override
  String get keptPhotosTitle => '已保留照片';

  @override
  String get keptVideosTitle => '已保留视频';

  @override
  String get keptEmptyPhotos => '暂无已保留的照片';

  @override
  String get keptEmptyVideos => '暂无已保留的视频';

  @override
  String get keptEmptyHint => '左滑保留的照片会显示在这里';

  @override
  String keptStatsPhotos(Object count) {
    return '共 $count 个照片已保留，尚未分类';
  }

  @override
  String keptStatsVideos(Object count) {
    return '共 $count 个视频已保留，尚未分类';
  }

  @override
  String get assignToCategory => '分配到分类';

  @override
  String get restoreToUnorganized => '恢复为待整理';

  @override
  String get restoreToUnorganizedHint => '回到整理队列重新处理';

  @override
  String get cannotGetFile => '无法获取文件';

  @override
  String get createCategoryFirst => '请先创建分类';

  @override
  String assignedToCategory(Object name) {
    return '已分配到「$name」';
  }

  @override
  String confirmRestoreKept(Object count) {
    return '确定将选中的 $count 个恢复为待整理状态？\n恢复后需要重新处理。';
  }

  @override
  String confirmMoveKeptToRecycle(Object count) {
    return '确定将选中的 $count 个移到回收站？\n30天后将自动永久删除。';
  }
}
