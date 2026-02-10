import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePrecacheService extends GetxService {

  /// Pre-caches a list of URLs into the system cache
  Future<void> precacheImages(List<String> urls, BuildContext context) async {
    for (String url in urls) {
      if (url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  /// High Priority: Pre-cache just the top banner
  Future<void> precacheHero(String url, BuildContext context) async {
    await precacheImage(CachedNetworkImageProvider(url), context);
  }
}