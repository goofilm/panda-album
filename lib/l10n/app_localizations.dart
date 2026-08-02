import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'熊猫相册'**
  String get appTitle;

  /// No description provided for @photoOrganize.
  ///
  /// In zh, this message translates to:
  /// **'照片整理'**
  String get photoOrganize;

  /// No description provided for @videoOrganize.
  ///
  /// In zh, this message translates to:
  /// **'视频整理'**
  String get videoOrganize;

  /// No description provided for @photo.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get video;

  /// No description provided for @category.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get category;

  /// No description provided for @kept.
  ///
  /// In zh, this message translates to:
  /// **'已保留'**
  String get kept;

  /// No description provided for @private.
  ///
  /// In zh, this message translates to:
  /// **'私密'**
  String get private;

  /// No description provided for @recycleBin.
  ///
  /// In zh, this message translates to:
  /// **'回收站'**
  String get recycleBin;

  /// No description provided for @startOrganize.
  ///
  /// In zh, this message translates to:
  /// **'开始整理'**
  String get startOrganize;

  /// No description provided for @swipeHint.
  ///
  /// In zh, this message translates to:
  /// **'左滑保留 · 右滑删除 · 下滑分类'**
  String get swipeHint;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'settings'**
  String get settings;

  /// No description provided for @lock.
  ///
  /// In zh, this message translates to:
  /// **'锁定'**
  String get lock;

  /// No description provided for @select.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get select;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @restore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get restore;

  /// No description provided for @moveToRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'移到回收站'**
  String get moveToRecycleBin;

  /// No description provided for @confirmMoveToRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'确定将选中的 {count} 张移到回收站？'**
  String confirmMoveToRecycleBin(Object count);

  /// No description provided for @permanentlyDelete.
  ///
  /// In zh, this message translates to:
  /// **'永久删除'**
  String get permanentlyDelete;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'清空回收站'**
  String get emptyRecycleBin;

  /// No description provided for @createCategory.
  ///
  /// In zh, this message translates to:
  /// **'新建分类'**
  String get createCategory;

  /// No description provided for @categoryName.
  ///
  /// In zh, this message translates to:
  /// **'分类名称'**
  String get categoryName;

  /// No description provided for @selectIcon.
  ///
  /// In zh, this message translates to:
  /// **'选择图标'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get selectColor;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// No description provided for @privateAlbum.
  ///
  /// In zh, this message translates to:
  /// **'私密相册'**
  String get privateAlbum;

  /// No description provided for @createPrivateAlbum.
  ///
  /// In zh, this message translates to:
  /// **'创建私密相册'**
  String get createPrivateAlbum;

  /// No description provided for @createPrivateVideoAlbum.
  ///
  /// In zh, this message translates to:
  /// **'创建私密视频相册'**
  String get createPrivateVideoAlbum;

  /// No description provided for @albumName.
  ///
  /// In zh, this message translates to:
  /// **'相册名称'**
  String get albumName;

  /// No description provided for @photoAlbum.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get photoAlbum;

  /// No description provided for @videoAlbum.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get videoAlbum;

  /// No description provided for @enterPin.
  ///
  /// In zh, this message translates to:
  /// **'请输入PIN码'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In zh, this message translates to:
  /// **'PIN码错误'**
  String get wrongPin;

  /// No description provided for @setPin.
  ///
  /// In zh, this message translates to:
  /// **'设置PIN码'**
  String get setPin;

  /// No description provided for @changePin.
  ///
  /// In zh, this message translates to:
  /// **'修改PIN码'**
  String get changePin;

  /// No description provided for @closePin.
  ///
  /// In zh, this message translates to:
  /// **'关闭PIN保护'**
  String get closePin;

  /// No description provided for @membership.
  ///
  /// In zh, this message translates to:
  /// **'会员'**
  String get membership;

  /// No description provided for @membershipCenter.
  ///
  /// In zh, this message translates to:
  /// **'会员中心'**
  String get membershipCenter;

  /// No description provided for @openMembership.
  ///
  /// In zh, this message translates to:
  /// **'开通会员'**
  String get openMembership;

  /// No description provided for @premiumMember.
  ///
  /// In zh, this message translates to:
  /// **'尊贵的会员'**
  String get premiumMember;

  /// No description provided for @pandaVip.
  ///
  /// In zh, this message translates to:
  /// **'熊猫相册 VIP'**
  String get pandaVip;

  /// No description provided for @thankSupport.
  ///
  /// In zh, this message translates to:
  /// **'感谢您的支持'**
  String get thankSupport;

  /// No description provided for @unlockAll.
  ///
  /// In zh, this message translates to:
  /// **'解锁全部功能，畅享完整体验'**
  String get unlockAll;

  /// No description provided for @premiumBenefits.
  ///
  /// In zh, this message translates to:
  /// **'会员专享权益'**
  String get premiumBenefits;

  /// No description provided for @unlimitedCategory.
  ///
  /// In zh, this message translates to:
  /// **'无限分类'**
  String get unlimitedCategory;

  /// No description provided for @unlimitedCategoryDesc.
  ///
  /// In zh, this message translates to:
  /// **'自由创建任意数量分类'**
  String get unlimitedCategoryDesc;

  /// No description provided for @unlimitedPrivate.
  ///
  /// In zh, this message translates to:
  /// **'无限私密'**
  String get unlimitedPrivate;

  /// No description provided for @unlimitedPrivateDesc.
  ///
  /// In zh, this message translates to:
  /// **'私密相册不再受限'**
  String get unlimitedPrivateDesc;

  /// No description provided for @permanentRecycle.
  ///
  /// In zh, this message translates to:
  /// **'永久回收站'**
  String get permanentRecycle;

  /// No description provided for @permanentRecycleDesc.
  ///
  /// In zh, this message translates to:
  /// **'回收站照片不会被自动清理'**
  String get permanentRecycleDesc;

  /// No description provided for @prioritySupport.
  ///
  /// In zh, this message translates to:
  /// **'优先客服'**
  String get prioritySupport;

  /// No description provided for @prioritySupportDesc.
  ///
  /// In zh, this message translates to:
  /// **'专属客服快速响应'**
  String get prioritySupportDesc;

  /// No description provided for @yearlyPlan.
  ///
  /// In zh, this message translates to:
  /// **'年度会员'**
  String get yearlyPlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In zh, this message translates to:
  /// **'月度会员'**
  String get monthlyPlan;

  /// No description provided for @yearlyPrice.
  ///
  /// In zh, this message translates to:
  /// **'¥25'**
  String get yearlyPrice;

  /// No description provided for @monthlyPrice.
  ///
  /// In zh, this message translates to:
  /// **'¥3'**
  String get monthlyPrice;

  /// No description provided for @perYear.
  ///
  /// In zh, this message translates to:
  /// **'/年'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In zh, this message translates to:
  /// **'/月'**
  String get perMonth;

  /// No description provided for @savePercent.
  ///
  /// In zh, this message translates to:
  /// **'省 31%'**
  String get savePercent;

  /// No description provided for @autoRenew.
  ///
  /// In zh, this message translates to:
  /// **'自动续费，随时取消'**
  String get autoRenew;

  /// No description provided for @subscribeNow.
  ///
  /// In zh, this message translates to:
  /// **'立即开通'**
  String get subscribeNow;

  /// No description provided for @restorePurchase.
  ///
  /// In zh, this message translates to:
  /// **'恢复购买'**
  String get restorePurchase;

  /// No description provided for @subscriptionNote.
  ///
  /// In zh, this message translates to:
  /// **'订阅说明：\n• 订阅到期后自动续费，可在应用商店随时取消\n• 取消后当前周期内仍可使用会员功能\n• 到期后未续费将恢复免费版\n• 所有价格均含税'**
  String get subscriptionNote;

  /// No description provided for @freeLimit.
  ///
  /// In zh, this message translates to:
  /// **'免费版限制'**
  String get freeLimit;

  /// No description provided for @freeCategoryLimit.
  ///
  /// In zh, this message translates to:
  /// **'免费版最多创建 {limit} 个分类'**
  String freeCategoryLimit(Object limit);

  /// No description provided for @freePrivateLimit.
  ///
  /// In zh, this message translates to:
  /// **'免费版最多创建 {limit} 个私密相册'**
  String freePrivateLimit(Object limit);

  /// No description provided for @upgradeToPremium.
  ///
  /// In zh, this message translates to:
  /// **'开通会员可创建无限分类'**
  String get upgradeToPremium;

  /// No description provided for @upgradeToPremiumPrivate.
  ///
  /// In zh, this message translates to:
  /// **'开通会员可创建无限私密相册'**
  String get upgradeToPremiumPrivate;

  /// No description provided for @permanentlyKept.
  ///
  /// In zh, this message translates to:
  /// **'永久保留'**
  String get permanentlyKept;

  /// No description provided for @daysRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余{days}天'**
  String daysRemaining(Object days);

  /// No description provided for @expired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get expired;

  /// No description provided for @scanPhotos.
  ///
  /// In zh, this message translates to:
  /// **'开始扫描'**
  String get scanPhotos;

  /// No description provided for @rescan.
  ///
  /// In zh, this message translates to:
  /// **'重新扫描'**
  String get rescan;

  /// No description provided for @scanning.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描'**
  String get scanning;

  /// No description provided for @analyzing.
  ///
  /// In zh, this message translates to:
  /// **'正在分析'**
  String get analyzing;

  /// No description provided for @scanComplete.
  ///
  /// In zh, this message translates to:
  /// **'扫描完成'**
  String get scanComplete;

  /// No description provided for @noDuplicates.
  ///
  /// In zh, this message translates to:
  /// **'没有发现重复照片'**
  String get noDuplicates;

  /// No description provided for @foundDuplicates.
  ///
  /// In zh, this message translates to:
  /// **'发现 {count} 组重复照片'**
  String foundDuplicates(Object count);

  /// No description provided for @keep.
  ///
  /// In zh, this message translates to:
  /// **'保留'**
  String get keep;

  /// No description provided for @allPhotosOrganized.
  ///
  /// In zh, this message translates to:
  /// **'所有照片已处理完成'**
  String get allPhotosOrganized;

  /// No description provided for @noTagData.
  ///
  /// In zh, this message translates to:
  /// **'暂无标签数据'**
  String get noTagData;

  /// No description provided for @noFaceData.
  ///
  /// In zh, this message translates to:
  /// **'暂无人物分组'**
  String get noFaceData;

  /// No description provided for @tapToCreate.
  ///
  /// In zh, this message translates to:
  /// **'点击\"开始检测\"自动识别人脸并分组'**
  String get tapToCreate;

  /// No description provided for @detecting.
  ///
  /// In zh, this message translates to:
  /// **'检测中'**
  String get detecting;

  /// No description provided for @startDetect.
  ///
  /// In zh, this message translates to:
  /// **'开始检测'**
  String get startDetect;

  /// No description provided for @redetect.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get redetect;

  /// No description provided for @photosWithFaces.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张照片含有人脸'**
  String photosWithFaces(Object count);

  /// No description provided for @personGroups.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个人物分组'**
  String personGroups(Object count);

  /// No description provided for @untitled.
  ///
  /// In zh, this message translates to:
  /// **'未命名'**
  String get untitled;

  /// No description provided for @createTime.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get createTime;

  /// No description provided for @renameGroup.
  ///
  /// In zh, this message translates to:
  /// **'重命名分组'**
  String get renameGroup;

  /// No description provided for @enterName.
  ///
  /// In zh, this message translates to:
  /// **'输入人物名称'**
  String get enterName;

  /// No description provided for @noPhotos.
  ///
  /// In zh, this message translates to:
  /// **'暂无照片'**
  String get noPhotos;

  /// No description provided for @organizedProgress.
  ///
  /// In zh, this message translates to:
  /// **'已整理 {organized} 张 / 共 {total} 张'**
  String organizedProgress(Object organized, Object total);

  /// No description provided for @organizedVideoProgress.
  ///
  /// In zh, this message translates to:
  /// **'已整理 {organized} 个 / 共 {total} 个'**
  String organizedVideoProgress(Object organized, Object total);

  /// No description provided for @scanningEllipsis.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描...'**
  String get scanningEllipsis;

  /// No description provided for @expireDate.
  ///
  /// In zh, this message translates to:
  /// **'到期时间: {date}'**
  String expireDate(Object date);

  /// No description provided for @purchaseSuccess.
  ///
  /// In zh, this message translates to:
  /// **'恭喜！{level}会员开通成功'**
  String purchaseSuccess(Object level);

  /// No description provided for @purchaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'购买失败，请稍后重试'**
  String get purchaseFailed;

  /// No description provided for @restoreSuccess.
  ///
  /// In zh, this message translates to:
  /// **'恢复购买成功'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'未找到可恢复的购买记录'**
  String get restoreFailed;

  /// No description provided for @yearly.
  ///
  /// In zh, this message translates to:
  /// **'年度'**
  String get yearly;

  /// No description provided for @monthly.
  ///
  /// In zh, this message translates to:
  /// **'月度'**
  String get monthly;

  /// No description provided for @myCategories.
  ///
  /// In zh, this message translates to:
  /// **'我的分类'**
  String get myCategories;

  /// No description provided for @photoCategoryCount.
  ///
  /// In zh, this message translates to:
  /// **'照片分类 {count} 个 · 已收纳 {organized} 张'**
  String photoCategoryCount(Object count, Object organized);

  /// No description provided for @videoCategoryCount.
  ///
  /// In zh, this message translates to:
  /// **'视频分类 {count} 个'**
  String videoCategoryCount(Object count);

  /// No description provided for @photoCategoryTab.
  ///
  /// In zh, this message translates to:
  /// **'照片分类 ({count})'**
  String photoCategoryTab(Object count);

  /// No description provided for @videoCategoryTab.
  ///
  /// In zh, this message translates to:
  /// **'视频分类 ({count})'**
  String videoCategoryTab(Object count);

  /// No description provided for @privateVideoAlbum.
  ///
  /// In zh, this message translates to:
  /// **'私密视频相册'**
  String get privateVideoAlbum;

  /// No description provided for @privatePhotoAlbum.
  ///
  /// In zh, this message translates to:
  /// **'私密照片相册'**
  String get privatePhotoAlbum;

  /// No description provided for @privateProtected.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个{type}已保护'**
  String privateProtected(Object count, Object type);

  /// No description provided for @enterPrivateSpace.
  ///
  /// In zh, this message translates to:
  /// **'点击进入私密空间'**
  String get enterPrivateSpace;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @mergeTo.
  ///
  /// In zh, this message translates to:
  /// **'合并到...'**
  String get mergeTo;

  /// No description provided for @editCategory.
  ///
  /// In zh, this message translates to:
  /// **'编辑分类'**
  String get editCategory;

  /// No description provided for @iconLabel.
  ///
  /// In zh, this message translates to:
  /// **'图标'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get colorLabel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @deleteCategory.
  ///
  /// In zh, this message translates to:
  /// **'删除分类'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」？'**
  String confirmDeleteCategory(Object name);

  /// No description provided for @confirmDeleteCategoryWithPhotos.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」？\n该分类下 {count} 张照片将回到待整理状态，需要重新分类。'**
  String confirmDeleteCategoryWithPhotos(Object count, Object name);

  /// No description provided for @mergedTo.
  ///
  /// In zh, this message translates to:
  /// **'已合并到「{name}」'**
  String mergedTo(Object name);

  /// No description provided for @itemsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String itemsCount(Object count);

  /// No description provided for @recycleBinEmpty.
  ///
  /// In zh, this message translates to:
  /// **'回收站是空的'**
  String get recycleBinEmpty;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// No description provided for @dateMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String dateMonthDay(Object day, Object month);

  /// No description provided for @groupItemCount.
  ///
  /// In zh, this message translates to:
  /// **'{label} · {count} 张'**
  String groupItemCount(Object count, Object label);

  /// No description provided for @confirmPermanentDeletePhoto.
  ///
  /// In zh, this message translates to:
  /// **'确定永久删除此照片？此操作不可恢复。'**
  String get confirmPermanentDeletePhoto;

  /// No description provided for @restoreAll.
  ///
  /// In zh, this message translates to:
  /// **'全部恢复'**
  String get restoreAll;

  /// No description provided for @clearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空所有'**
  String get clearAll;

  /// No description provided for @selectAllText.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAllText;

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @confirmPermanentDeleteSelected.
  ///
  /// In zh, this message translates to:
  /// **'确定永久删除选中的 {count} 张照片？'**
  String confirmPermanentDeleteSelected(Object count);

  /// No description provided for @confirmClearRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'确定清空回收站？此操作不可恢复。'**
  String get confirmClearRecycleBin;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @createVideoCategory.
  ///
  /// In zh, this message translates to:
  /// **'创建视频分类'**
  String get createVideoCategory;

  /// No description provided for @createCategoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'创建分类'**
  String get createCategoryTitle;

  /// No description provided for @categoryNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：宝宝、宠物、汽车'**
  String get categoryNameHint;

  /// No description provided for @saveCategory.
  ///
  /// In zh, this message translates to:
  /// **'保存分类'**
  String get saveCategory;

  /// No description provided for @enterCategoryName.
  ///
  /// In zh, this message translates to:
  /// **'请输入分类名称'**
  String get enterCategoryName;

  /// No description provided for @tapHint.
  ///
  /// In zh, this message translates to:
  /// **'点击查看 · 长按操作 · 全屏上下滑动切换'**
  String get tapHint;

  /// No description provided for @currentName.
  ///
  /// In zh, this message translates to:
  /// **'当前: {name}'**
  String currentName(Object name);

  /// No description provided for @changeCategory.
  ///
  /// In zh, this message translates to:
  /// **'修改分类'**
  String get changeCategory;

  /// No description provided for @moveToPrivate.
  ///
  /// In zh, this message translates to:
  /// **'移入私密相册'**
  String get moveToPrivate;

  /// No description provided for @removeFromCategory.
  ///
  /// In zh, this message translates to:
  /// **'移出分类'**
  String get removeFromCategory;

  /// No description provided for @remove.
  ///
  /// In zh, this message translates to:
  /// **'移出'**
  String get remove;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 项'**
  String selectedCount(Object count);

  /// No description provided for @enterPhotoName.
  ///
  /// In zh, this message translates to:
  /// **'输入照片/视频名称'**
  String get enterPhotoName;

  /// No description provided for @noOtherCategories.
  ///
  /// In zh, this message translates to:
  /// **'没有其他可用的分类，请先创建'**
  String get noOtherCategories;

  /// No description provided for @moveToCategory.
  ///
  /// In zh, this message translates to:
  /// **'移动到分类'**
  String get moveToCategory;

  /// No description provided for @photoCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张'**
  String photoCount(Object count);

  /// No description provided for @movedTo.
  ///
  /// In zh, this message translates to:
  /// **'已移动到「{name}」'**
  String movedTo(Object name);

  /// No description provided for @createPrivatePhotoAlbumFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先创建私密照片相册'**
  String get createPrivatePhotoAlbumFirst;

  /// No description provided for @createPrivateVideoAlbumFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先创建私密视频相册'**
  String get createPrivateVideoAlbumFirst;

  /// No description provided for @selectPrivateAlbum.
  ///
  /// In zh, this message translates to:
  /// **'选择私密相册'**
  String get selectPrivateAlbum;

  /// No description provided for @albumProtected.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个已保护'**
  String albumProtected(Object count);

  /// No description provided for @movedToPrivateAlbum.
  ///
  /// In zh, this message translates to:
  /// **'已移入「{name}」私密相册'**
  String movedToPrivateAlbum(Object name);

  /// No description provided for @confirmRemoveFromCategory.
  ///
  /// In zh, this message translates to:
  /// **'确定将选中的 {count} 张移出当前分类？\n移出后需要重新整理。'**
  String confirmRemoveFromCategory(Object count);

  /// No description provided for @confirmMoveToRecycleBinDetail.
  ///
  /// In zh, this message translates to:
  /// **'确定将选中的 {count} 张移到回收站？\n30天后将自动永久删除。'**
  String confirmMoveToRecycleBinDetail(Object count);

  /// No description provided for @preview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get preview;

  /// No description provided for @videoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get videoLoadFailed;

  /// No description provided for @defaultCatWork.
  ///
  /// In zh, this message translates to:
  /// **'工作'**
  String get defaultCatWork;

  /// No description provided for @defaultCatLife.
  ///
  /// In zh, this message translates to:
  /// **'生活'**
  String get defaultCatLife;

  /// No description provided for @defaultCatTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行'**
  String get defaultCatTravel;

  /// No description provided for @defaultCatFood.
  ///
  /// In zh, this message translates to:
  /// **'美食'**
  String get defaultCatFood;

  /// No description provided for @defaultCatScreenshot.
  ///
  /// In zh, this message translates to:
  /// **'截图'**
  String get defaultCatScreenshot;

  /// No description provided for @defaultCatPortrait.
  ///
  /// In zh, this message translates to:
  /// **'人像'**
  String get defaultCatPortrait;

  /// No description provided for @defaultCatVlog.
  ///
  /// In zh, this message translates to:
  /// **'Vlog'**
  String get defaultCatVlog;

  /// No description provided for @defaultCatTutorial.
  ///
  /// In zh, this message translates to:
  /// **'教程'**
  String get defaultCatTutorial;

  /// No description provided for @defaultCatPet.
  ///
  /// In zh, this message translates to:
  /// **'宠物'**
  String get defaultCatPet;

  /// No description provided for @defaultCatSports.
  ///
  /// In zh, this message translates to:
  /// **'运动'**
  String get defaultCatSports;

  /// No description provided for @defaultCatMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐'**
  String get defaultCatMusic;

  /// No description provided for @defaultCatScreenRecord.
  ///
  /// In zh, this message translates to:
  /// **'录屏'**
  String get defaultCatScreenRecord;

  /// No description provided for @activateWithCode.
  ///
  /// In zh, this message translates to:
  /// **'使用激活码'**
  String get activateWithCode;

  /// No description provided for @activateCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您购买的激活码，格式：PANDA-XXXXXXXX-X'**
  String get activateCodeHint;

  /// No description provided for @activateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'激活成功！会员已开通'**
  String get activateSuccess;

  /// No description provided for @activateAlreadyUsed.
  ///
  /// In zh, this message translates to:
  /// **'该激活码已被使用'**
  String get activateAlreadyUsed;

  /// No description provided for @activateInvalid.
  ///
  /// In zh, this message translates to:
  /// **'激活码无效，请检查后重试'**
  String get activateInvalid;

  /// No description provided for @scanToPurchase.
  ///
  /// In zh, this message translates to:
  /// **'扫码购买会员'**
  String get scanToPurchase;

  /// No description provided for @purchaseQRHint.
  ///
  /// In zh, this message translates to:
  /// **'请使用支付宝或微信扫码付款\n月卡 ¥3 · 年卡 ¥25'**
  String get purchaseQRHint;

  /// No description provided for @purchaseQRNote.
  ///
  /// In zh, this message translates to:
  /// **'付款后请将截图发送至 goofilm@163.com\n我们将尽快发送激活码'**
  String get purchaseQRNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
