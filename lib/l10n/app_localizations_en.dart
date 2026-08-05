// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Panda Album';

  @override
  String get photoOrganize => 'Photo Organizer';

  @override
  String get videoOrganize => 'Video Organizer';

  @override
  String get photo => 'Photos';

  @override
  String get video => 'Videos';

  @override
  String get category => 'Categories';

  @override
  String get kept => 'Kept';

  @override
  String get private => 'Private';

  @override
  String get recycleBin => 'Recycle Bin';

  @override
  String get startOrganize => 'Start Organizing';

  @override
  String get swipeHint =>
      'Swipe left to keep · right to delete · down to categorize';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get lock => 'Lock';

  @override
  String get select => 'Select';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get share => 'Share';

  @override
  String get restore => 'Restore';

  @override
  String get moveToRecycleBin => 'Move to Recycle Bin';

  @override
  String confirmMoveToRecycleBin(Object count) {
    return 'Move $count selected items to Recycle Bin?';
  }

  @override
  String get permanentlyDelete => 'Permanently Delete';

  @override
  String get emptyRecycleBin => 'Empty Recycle Bin';

  @override
  String get createCategory => 'New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get create => 'Create';

  @override
  String get privateAlbum => 'Private Album';

  @override
  String get createPrivateAlbum => 'Create Private Album';

  @override
  String get createPrivateVideoAlbum => 'Create Private Video Album';

  @override
  String get albumName => 'Album Name';

  @override
  String get photoAlbum => 'Photos';

  @override
  String get videoAlbum => 'Videos';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get wrongPin => 'Incorrect PIN';

  @override
  String get setPin => 'Set PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get closePin => 'Disable PIN Protection';

  @override
  String get membership => 'Membership';

  @override
  String get membershipCenter => 'Membership Center';

  @override
  String get openMembership => 'Subscribe';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get pandaVip => 'Panda Album VIP';

  @override
  String get thankSupport => 'Thank you for your support';

  @override
  String get unlockAll => 'Ad-free, enjoy the full experience';

  @override
  String get premiumBenefits => 'Premium Benefits';

  @override
  String get adFreeBenefit => 'Completely Ad-Free';

  @override
  String get adFreeBenefitDesc => 'No splash, banner or any ads';

  @override
  String get splashAdBenefit => 'No Splash Ads';

  @override
  String get splashAdBenefitDesc => 'Open the app and go straight to home';

  @override
  String get prioritySupport => 'Priority Support';

  @override
  String get prioritySupportDesc => 'Dedicated customer service';

  @override
  String get yearlyPlan => 'Yearly';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get yearlyPrice => '\$3';

  @override
  String get monthlyPrice => '\$1';

  @override
  String get perYear => '/year';

  @override
  String get perMonth => '/month';

  @override
  String get savePercent => 'Save 58%';

  @override
  String get autoRenew => 'No auto-renewal after expiration';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get subscriptionNote =>
      'How to subscribe:\n• Tap Subscribe to visit our official store\n• Activation code is delivered automatically after payment\n• Enter the code below to remove all ads\n• Reverts to free version after expiration';

  @override
  String skipAd(Object seconds) {
    return 'Skip ${seconds}s';
  }

  @override
  String get freeLimit => 'Free Version Limit';

  @override
  String freeCategoryLimit(Object limit) {
    return 'Free version allows up to $limit categories';
  }

  @override
  String freePrivateLimit(Object limit) {
    return 'Free version allows up to $limit private album';
  }

  @override
  String get upgradeToPremium => 'Upgrade to Premium for unlimited categories';

  @override
  String get upgradeToPremiumPrivate =>
      'Upgrade to Premium for unlimited private albums';

  @override
  String get permanentlyKept => 'Permanent';

  @override
  String daysRemaining(Object days) {
    return '$days days left';
  }

  @override
  String get expired => 'Expired';

  @override
  String get scanPhotos => 'Start Scan';

  @override
  String get rescan => 'Rescan';

  @override
  String get scanning => 'Scanning';

  @override
  String get analyzing => 'Analyzing';

  @override
  String get scanComplete => 'Scan Complete';

  @override
  String get noDuplicates => 'No duplicate photos found';

  @override
  String foundDuplicates(Object count) {
    return 'Found $count groups of duplicate photos';
  }

  @override
  String get keep => 'Keep';

  @override
  String get allPhotosOrganized => 'All photos have been processed';

  @override
  String get noTagData => 'No tag data';

  @override
  String get noFaceData => 'No face groups';

  @override
  String get tapToCreate => 'Tap \"Start Detection\" to auto-detect faces';

  @override
  String get detecting => 'Detecting';

  @override
  String get startDetect => 'Start Detection';

  @override
  String get redetect => 'Redetect';

  @override
  String photosWithFaces(Object count) {
    return '$count photos with faces';
  }

  @override
  String personGroups(Object count) {
    return '$count person groups';
  }

  @override
  String get untitled => 'Untitled';

  @override
  String get createTime => 'Created';

  @override
  String get renameGroup => 'Rename Group';

  @override
  String get enterName => 'Enter name';

  @override
  String get noPhotos => 'No photos';

  @override
  String organizedProgress(Object organized, Object total) {
    return '$organized of $total organized';
  }

  @override
  String organizedVideoProgress(Object organized, Object total) {
    return '$organized of $total organized';
  }

  @override
  String get scanningEllipsis => 'Scanning...';

  @override
  String expireDate(Object date) {
    return 'Expires: $date';
  }

  @override
  String purchaseSuccess(Object level) {
    return 'Success! $level membership activated';
  }

  @override
  String get purchaseFailed => 'Purchase failed, please try again';

  @override
  String get restoreSuccess => 'Purchase restored successfully';

  @override
  String get restoreFailed => 'No restorable purchases found';

  @override
  String get yearly => 'Yearly';

  @override
  String get monthly => 'Monthly';

  @override
  String get myCategories => 'My Categories';

  @override
  String photoCategoryCount(Object count, Object organized) {
    return '$count photo categories · $organized organized';
  }

  @override
  String videoCategoryCount(Object count) {
    return '$count video categories';
  }

  @override
  String photoCategoryTab(Object count) {
    return 'Photos ($count)';
  }

  @override
  String videoCategoryTab(Object count) {
    return 'Videos ($count)';
  }

  @override
  String get privateVideoAlbum => 'Private Video Album';

  @override
  String get privatePhotoAlbum => 'Private Photo Album';

  @override
  String privateProtected(Object count, Object type) {
    return '$count $type protected';
  }

  @override
  String get enterPrivateSpace => 'Tap to enter private space';

  @override
  String get rename => 'Rename';

  @override
  String get mergeTo => 'Merge to...';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get save => 'Save';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String confirmDeleteCategory(Object name) {
    return 'Delete \'$name\'?';
  }

  @override
  String confirmDeleteCategoryWithPhotos(Object count, Object name) {
    return 'Delete \'$name\'?\n$count photos will return to unorganized status.';
  }

  @override
  String mergedTo(Object name) {
    return 'Merged to \'$name\'';
  }

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get recycleBinEmpty => 'Recycle bin is empty';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String dateMonthDay(Object day, Object month) {
    return '$month/$day';
  }

  @override
  String groupItemCount(Object count, Object label) {
    return '$label · $count';
  }

  @override
  String get confirmPermanentDeletePhoto =>
      'Permanently delete this photo? This cannot be undone.';

  @override
  String get restoreAll => 'Restore All';

  @override
  String get clearAll => 'Clear All';

  @override
  String get selectAllText => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String confirmPermanentDeleteSelected(Object count) {
    return 'Permanently delete $count selected photos?';
  }

  @override
  String get confirmClearRecycleBin =>
      'Clear recycle bin? This cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get createVideoCategory => 'Create Video Category';

  @override
  String get createCategoryTitle => 'Create Category';

  @override
  String get categoryNameHint => 'e.g. Baby, Pet, Car';

  @override
  String get saveCategory => 'Save Category';

  @override
  String get enterCategoryName => 'Please enter a category name';

  @override
  String get tapHint =>
      'Tap to view · Long press for options · Swipe to switch';

  @override
  String currentName(Object name) {
    return 'Current: $name';
  }

  @override
  String get changeCategory => 'Change Category';

  @override
  String get moveToPrivate => 'Move to Private Album';

  @override
  String get removeFromCategory => 'Remove from Category';

  @override
  String get remove => 'Remove';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get enterPhotoName => 'Enter photo/video name';

  @override
  String get noOtherCategories =>
      'No other categories available, please create one';

  @override
  String get moveToCategory => 'Move to Category';

  @override
  String photoCount(Object count) {
    return '$count items';
  }

  @override
  String movedTo(Object name) {
    return 'Moved to \'$name\'';
  }

  @override
  String get createPrivatePhotoAlbumFirst =>
      'Please create a private photo album first';

  @override
  String get createPrivateVideoAlbumFirst =>
      'Please create a private video album first';

  @override
  String get selectPrivateAlbum => 'Select Private Album';

  @override
  String albumProtected(Object count) {
    return '$count protected';
  }

  @override
  String movedToPrivateAlbum(Object name) {
    return 'Moved to private album \'$name\'';
  }

  @override
  String confirmRemoveFromCategory(Object count) {
    return 'Remove $count selected items from this category?\nYou\'ll need to reorganize them.';
  }

  @override
  String confirmMoveToRecycleBinDetail(Object count) {
    return 'Move $count selected items to Recycle Bin?\nThey will be permanently deleted after 30 days.';
  }

  @override
  String get preview => 'Preview';

  @override
  String get videoLoadFailed => 'Video load failed';

  @override
  String get defaultCatWork => 'Work';

  @override
  String get defaultCatLife => 'Life';

  @override
  String get defaultCatTravel => 'Travel';

  @override
  String get defaultCatFood => 'Food';

  @override
  String get defaultCatScreenshot => 'Screenshots';

  @override
  String get defaultCatPortrait => 'Portrait';

  @override
  String get defaultCatVlog => 'Vlog';

  @override
  String get defaultCatTutorial => 'Tutorial';

  @override
  String get defaultCatPet => 'Pet';

  @override
  String get defaultCatSports => 'Sports';

  @override
  String get defaultCatMusic => 'Music';

  @override
  String get defaultCatScreenRecord => 'Screen Record';

  @override
  String get activateWithCode => 'Activate with Code';

  @override
  String get activateCodeHint =>
      'Enter your activation code. Format: PANDA-XXXXXXXX-X';

  @override
  String get activateSuccess => 'Activation successful! Premium unlocked';

  @override
  String get activateAlreadyUsed => 'This code has already been used';

  @override
  String get activateInvalid => 'Invalid code, please check and try again';

  @override
  String get scanToPurchase => 'Purchase Membership';

  @override
  String get purchaseQRHint =>
      'Tap Subscribe to visit our official store\nMonthly \$1 · Yearly \$3';

  @override
  String get purchaseQRNote =>
      'Activation code is delivered automatically after payment';

  @override
  String get membershipExpired => 'Membership Expired';

  @override
  String get categoryPremiumRequired =>
      'Category organization requires premium membership. Please renew to continue.';

  @override
  String get screenshotCleanup => 'Screenshot Cleanup';

  @override
  String screenshotTotal(Object count) {
    return '$count screenshots';
  }

  @override
  String get screenshotNotFound => 'No screenshots found';

  @override
  String screenshotSelected(Object count) {
    return '$count selected';
  }

  @override
  String get screenshotSelectAll => 'Select All';

  @override
  String get screenshotDeselectAll => 'Deselect All';

  @override
  String screenshotConfirmDelete(Object count) {
    return 'Delete $count selected screenshots?';
  }

  @override
  String screenshotDeleted(Object count) {
    return '$count screenshots deleted';
  }

  @override
  String get screenshotCleanDesc =>
      'Clean up unwanted screenshots to free up storage';

  @override
  String get keptPhotosTitle => 'Kept Photos';

  @override
  String get keptVideosTitle => 'Kept Videos';

  @override
  String get keptEmptyPhotos => 'No kept photos yet';

  @override
  String get keptEmptyVideos => 'No kept videos yet';

  @override
  String get keptEmptyHint => 'Photos kept by swiping left will appear here';

  @override
  String keptStatsPhotos(Object count) {
    return '$count photos kept, not categorized yet';
  }

  @override
  String keptStatsVideos(Object count) {
    return '$count videos kept, not categorized yet';
  }

  @override
  String get assignToCategory => 'Assign to Category';

  @override
  String get restoreToUnorganized => 'Restore to Unsorted';

  @override
  String get restoreToUnorganizedHint => 'Return to the organizing queue';

  @override
  String get cannotGetFile => 'Unable to get file';

  @override
  String get createCategoryFirst => 'Please create a category first';

  @override
  String assignedToCategory(Object name) {
    return 'Assigned to \"$name\"';
  }

  @override
  String confirmRestoreKept(Object count) {
    return 'Restore $count selected items to unsorted?\nThey will need to be processed again.';
  }

  @override
  String confirmMoveKeptToRecycle(Object count) {
    return 'Move $count selected items to the recycle bin?\nThey will be permanently deleted after 30 days.';
  }
}
