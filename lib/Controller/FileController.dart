import 'dart:convert';
import 'dart:io';
import 'package:googleapis/connectors/v1.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart'; // OAuth2.0 client
import 'package:googleapis/drive/v3.dart' as drive; // Google Drive API
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class FileController extends GetxController {
  
  
Future<String?> uploadFileToCloudinarySigned(File file) async {
  // 🟢 Bước 1: Gọi NodeJS server để lấy chữ ký
  final signatureResponse = await http.post(
    Uri.parse('https://what-supserver.onrender.com/get-signature'), // 🔁 Đổi sau khi deploy
  );

  if (signatureResponse.statusCode != 200) {
    throw Exception('❌ Không lấy được chữ ký');
  }

  final signatureData = json.decode(signatureResponse.body);
  final apiKey = signatureData['apiKey'];
  final timestamp = signatureData['timestamp'].toString();
  final signature = signatureData['signature'];
  final cloudName = signatureData['cloudName'];

  // 🟢 Bước 2: Upload file lên Cloudinary
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

  final uploadRequest = http.MultipartRequest(
  'POST',
  Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload'), // ✅ dùng raw
)
  ..fields['api_key'] = apiKey
  ..fields['timestamp'] = timestamp
  ..fields['signature'] = signature
  ..fields['upload_preset'] = "What'sUpS" // nếu bạn đang dùng preset signed
  ..files.add(await http.MultipartFile.fromPath(
    'file',
    file.path,
    contentType: MediaType.parse(lookupMimeType(file.path) ?? 'application/octet-stream'),
  ));

  final uploadResponse = await uploadRequest.send();

// ✅ Chuyển từ StreamedResponse sang Response để xử lý dễ hơn
final response = await http.Response.fromStream(uploadResponse);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  print('✅ File uploaded: ${data['secure_url']}');
  return data['secure_url'];
} else {
  print("❌ Cloudinary Error: ${response.body}");
  throw Exception('❌ Upload thất bại');
}

}

 

  String? generatePreviewUrl(String secureUrl, String fileType) {
  if (fileType == 'pdf') {
    final publicId = getPublicIdFromUrl(secureUrl);
    return 'https://res.cloudinary.com/dod0lqxur/image/upload/pg_1/w_400,c_fit/$publicId.pdf';
  }
  return null; // file docx, zip không có preview
}
Future<void> uploadToCloudinary(String filePath) async {
  final file = File(filePath);

  // 🟢 B1: Kiểm tra file tồn tại
  if (!await file.exists()) {
    print('❌ File không tồn tại: $filePath');
    return;
  }

  // 🟢 B2: Thông tin Cloudinary
  const cloudName = 'dod0lqxur'; // 🔁 Đổi thành cloud_name của bạn
  const uploadPreset = "What'sUp"; // 🔁 Đảm bảo preset này là unsigned & bật public

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

  // 🟢 B3: Xác định MIME Type
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mimeType),
    ));

  // 🟢 B4: Gửi yêu cầu
  final response = await request.send();

  if (response.statusCode == 200) {
    final resBody = await response.stream.bytesToString();
    print('✅ Upload thành công!');
    print('🌐 URL: ${resBody}');
    final data = jsonDecode(resBody);
    final url = data['secure_url'];
    print('✅ Upload thành công: $url');
  } else {
    print('❌ Lỗi upload: ${response.statusCode}');
    print('📥 Response body: ${await response.stream.bytesToString()}');
  }
}
Future<String?> uploadToCloudinaryUrl(String filePath) async {
  final file = File(filePath);

  // 🟢 B1: Kiểm tra file có tồn tại không
  if (!await file.exists()) {
    print('❌ File không tồn tại: $filePath');
    return null;
  }

  // 🟢 B2: Cấu hình Cloudinary
  const cloudName = 'dod0lqxur'; // 👈 thay bằng cloud_name thật của bạn
  const uploadPreset = "What'sUp"; // 👈 preset phải là "unsigned" & bật "public"

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

  // 🟢 B3: Lấy MIME type (audio/m4a, etc.)
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mimeType),
    ));

  // 🟢 B4: Gửi request
  final response = await request.send();

  if (response.statusCode == 200) {
    final resBody = await response.stream.bytesToString();
    final data = jsonDecode(resBody);
    final url = data['secure_url'];
    print('✅ Upload thành công: $url');
    return url;
  } else {
    print('❌ Upload thất bại: ${response.statusCode}');
    final error = await response.stream.bytesToString();
    print('📥 Lỗi chi tiết: $error');
    return null;
  }
}
String getPublicIdFromUrl(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  final fileWithExt = segments.last; // vd: file.pdf
  final fileName = fileWithExt.replaceAll(RegExp(r'\.[^\.]+$'), ''); // bỏ đuôi
  return "raw/upload/v${segments[segments.length - 2].replaceAll('v', '')}/$fileName";
}
      Future<String> uploadFileToSupabase(File file) async {
  final supabase = Supabase.instance.client;

  final fileBytes = await file.readAsBytes();
  final fileName = file.path.split('/').last;
  final uploadPath = 'uploads/$fileName';

  final response = await supabase.storage
      .from('whatsup')
      .uploadBinary(
        uploadPath,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

  if (response.isEmpty) {
    throw Exception('❌ Upload thất bại');
  }

  final publicUrl = supabase.storage.from('whatsup').getPublicUrl(uploadPath);
  return publicUrl;
}


}