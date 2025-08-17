import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String name;

  const PdfViewerScreen({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(name, style: Theme.of(context).textTheme.labelSmall,)),
      body: PDF().fromUrl(
        url,
        placeholder: (progress) =>
            Center(child: Text('Đang tải... $progress%')),
        errorWidget: (error) =>
            Center(child: Text('Không mở được PDF\n$error')),
      ),
    );
  }
}
