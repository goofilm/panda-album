import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'features/splash/splash_ad_page.dart';

import 'providers/photo_provider.dart';
import 'providers/category_provider.dart';
import 'providers/private_album_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/locale_provider.dart';

class PhotoOrganizerApp extends StatelessWidget {
  const PhotoOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 语言设置
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),

        // 照片数据
        ChangeNotifierProvider(create: (_) => PhotoProvider()),

        // 分类数据
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        // 私密相册数据
        ChangeNotifierProvider(create: (_) => PrivateAlbumProvider()),

        // 会员状态
        ChangeNotifierProvider(create: (_) => MembershipProvider()..init()),
      ],

      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            title: "熊猫相册",

            // 动态切换语言
            locale: localeProvider.locale,

            // 多语言配置
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],

            theme: ThemeData(
              useMaterial3: true,

              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),

            home: const SplashAdPage(),
          );
        },
      ),
    );
  }
}
