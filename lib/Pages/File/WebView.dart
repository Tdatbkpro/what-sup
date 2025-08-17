import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class WordViewerScreen extends StatefulWidget {
  final String url;
  final String name;

  const WordViewerScreen({super.key, required this.url, required this.name});

  @override
  State<WordViewerScreen> createState() => _WordViewerScreenState();
}

class _WordViewerScreenState extends State<WordViewerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://docs.google.com/gview?embedded=true&url=${widget.url}'));
  }
  Future<void> _downloadFile() async {
  final status = await Permission.storage.request();

  if (status.isGranted) {
    try {
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      final savePath = "${dir!.path}/${widget.name}";
      final dio = Dio();

      await dio.download(widget.url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã tải xuống: ${widget.name}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tải xuống thất bại: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Không có quyền lưu tệp")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.name, style: TextStyle(fontSize: 20, color: Colors.white),),
        actions: [
          IconButton(onPressed: _downloadFile, icon: Icon(Icons.download_outlined))
        ],
        ),
      body: WebViewWidget(controller: _controller,
        layoutDirection: TextDirection.ltr,

      ),
    );
  }
}
