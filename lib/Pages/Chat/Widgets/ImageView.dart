import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:whats_up/Model/User.dart';

class Imageview extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final User user;

  const Imageview({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.user,
  });

  @override
  State<Imageview> createState() => _ImageviewState();
}

class _ImageviewState extends State<Imageview> {
  late final PageController _pageController;
  late final RxInt _currentIndex = widget.initialIndex.obs;

  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex.value);
  }

  Future<bool> checkStoragePermission() async {
    if (_isRequestingPermission) return false;

    _isRequestingPermission = true;

    try {
      if (Platform.isAndroid) {
        final androidVersion = int.tryParse(Platform.operatingSystemVersion.split(" ").firstWhere((e) => int.tryParse(e) != null, orElse: () => '0')) ?? 0;

        if (androidVersion >= 11) {
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          }
          final result = await Permission.manageExternalStorage.request();
          return result.isGranted;
        } else {
          if (await Permission.storage.isGranted) return true;
          final result = await Permission.storage.request();
          return result.isGranted;
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photosAddOnly.request();
        return status.isGranted;
      }
    } finally {
      _isRequestingPermission = false;
    }

    return false;
  }

  Future<void> downloadImage(String url) async {
    final hasPermission = await checkStoragePermission();
    if (!hasPermission) {
      Get.snackbar("Lỗi", "❌ Không có quyền truy cập bộ nhớ");
      return;
    }

    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List bytes = Uint8List.fromList(response.data);

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: "whatsup_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if ((result['isSuccess'] ?? false) == true) {
        Get.snackbar("Thành công", "✅ Ảnh đã được lưu vào thư viện");
      } else {
        Get.snackbar("Lỗi", "❌ Không thể lưu ảnh vào thư viện");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "❌ Lỗi khi tải ảnh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Obx( () =>
          Text(
                "Ảnh ${_currentIndex.value + 1}/${widget.imageUrls.length}",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
        ),
        leading: Text(
              "${widget.user.name}",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            automaticallyImplyLeading: true,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              final url = widget.imageUrls[_currentIndex.value];
              downloadImage(url);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => _currentIndex.value = index,
              itemBuilder: (context, index) {
                final imageUrl = widget.imageUrls[index];
                return InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SmoothPageIndicator(
                controller: _pageController,
                count: widget.imageUrls.length,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                ),
              ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
