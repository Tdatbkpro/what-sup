import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  final ImagePicker imagePicker = ImagePicker();
  
  final RxBool isPicking = false.obs;

 Future<String> pickImageWithChoice(BuildContext context) async {
  if (isPicking.value) return "";

  final ImageSource? source = await showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Chụp từ Camera
            InkWell(
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.camera_alt, size: 20),
                  ),
                  SizedBox(height: 8),
                  Text("Camera",  style: TextStyle(fontSize: 14),),
                ],
              ),
            ),

            // Chọn từ Gallery
            InkWell(
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.photo_library, size: 20),
                  ),
                  SizedBox(height: 8),
                  Text("Thư viện", style: TextStyle(fontSize: 14),),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  if (source == null) return "";

  try {
    isPicking.value = true;
    final XFile? image = await imagePicker.pickImage(source: source);
   //final List<XFile>? image =  await ImagePicker().pickMultiImage();
    return image?.path ?? "";
  } catch (e) {
    print("ImagePicker Error: $e");
    return "";
  } finally {
    isPicking.value = false;
  }
}

}
