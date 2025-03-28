/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/app_logo_512.png
  AssetGenImage get appLogo512 =>
      const AssetGenImage('assets/images/app_logo_512.png');

  /// File path: assets/images/inspection_pro_splash.PNG
  AssetGenImage get inspectionProSplash =>
      const AssetGenImage('assets/images/inspection_pro_splash.PNG');

  /// File path: assets/images/inspectionpro_title_caption.png
  AssetGenImage get inspectionproTitleCaption =>
      const AssetGenImage('assets/images/inspectionpro_title_caption.png');

  /// File path: assets/images/ip_logo.PNG
  AssetGenImage get ipLogo => const AssetGenImage('assets/images/ip_logo.PNG');

  /// File path: assets/images/logout.png
  AssetGenImage get logout => const AssetGenImage('assets/images/logout.png');

  /// File path: assets/images/main_logo.jpg
  AssetGenImage get mainLogo =>
      const AssetGenImage('assets/images/main_logo.jpg');

  /// File path: assets/images/sync.png
  AssetGenImage get sync => const AssetGenImage('assets/images/sync.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        appLogo512,
        inspectionProSplash,
        inspectionproTitleCaption,
        ipLogo,
        logout,
        mainLogo,
        sync
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const String inspection = 'assets/inspection.sqlite';

  /// List of all assets
  static List<String> get values => [inspection];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
