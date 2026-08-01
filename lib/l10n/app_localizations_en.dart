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
  String get unlockAll => 'Unlock all features, enjoy the full experience';

  @override
  String get premiumBenefits => 'Premium Benefits';

  @override
  String get unlimitedCategory => 'Unlimited Categories';

  @override
  String get unlimitedCategoryDesc => 'Create as many categories as you want';

  @override
  String get unlimitedPrivate => 'Unlimited Private Albums';

  @override
  String get unlimitedPrivateDesc => 'No limit on private albums';

  @override
  String get permanentRecycle => 'Permanent Recycle Bin';

  @override
  String get permanentRecycleDesc =>
      'Photos in recycle bin are never auto-deleted';

  @override
  String get prioritySupport => 'Priority Support';

  @override
  String get prioritySupportDesc => 'Dedicated customer service';

  @override
  String get yearlyPlan => 'Yearly';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get yearlyPrice => '\$13.99';

  @override
  String get monthlyPrice => '\$1.99';

  @override
  String get perYear => '/year';

  @override
  String get perMonth => '/month';

  @override
  String get savePercent => 'Save 38%';

  @override
  String get autoRenew => 'Auto-renew, cancel anytime';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get subscriptionNote =>
      'Subscription Info:\n• Auto-renews, cancel anytime in App Store\n• Full access during current period\n• Reverts to free after expiration\n• All prices include tax';

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
}
