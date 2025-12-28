import 'dart:io';
import 'dart:typed_data';

import 'package:chop_chop_africa/backend/support_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../backend/image_cache.dart';
import '../backend/profile_provider.dart';



final ImagePicker _picker = ImagePicker();
final ImageCacheManager _cacheManager = ImageCacheManager();
class ImageServices{
  Future<String?> pickImages(ImageSource source, String process, BuildContext context) async {
    XFile? file = await _picker.pickImage(source: source);
    try {
      if (file != null) {
        EasyLoading.show();
        File imageFile = File(file.path);
        int imageSizeInBytes = imageFile.lengthSync();
        double imageSizeInMB = imageSizeInBytes / (1024 * 1024);
        if (imageSizeInMB > 2) {
          double scaleFactor = 2 / imageSizeInMB;
          List<int> imageBytes = await resizeImage(imageFile, scaleFactor);
          file = await saveResizedImage(imageBytes);
        }
        if(process == 'changeAvatar'){
          Provider.of<ProfileProvider>(context,listen: false).changeAvatar(File(file.path));
        }else{
          Provider.of<SupportProvider>(context, listen: false).getSupportImage(file.path);
        }
        EasyLoading.dismiss();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error picking images: $e');
      // Handle errors as needed
      return null;
    }
  }

  Future<List<int>> resizeImage(File imageFile, double scaleFactor) async {
    String cacheKey = '${path.basename(imageFile.path)}_$scaleFactor';
    // Check if the resized image is already in the cache
    Uint8List? cachedImage = await _cacheManager.getImageFromCache(cacheKey);
    if (cachedImage != null) {
      print('Using cached image for resizing: $cacheKey');
      return cachedImage;
    }

    try {
      // Read original image bytes
      List<int> originalBytes = await imageFile.readAsBytes();

      // Get original image dimensions
      img.Image originalImage = img.decodeImage( Uint8List.fromList(originalBytes))!;
      int originalWidth = originalImage.width;
      int originalHeight = originalImage.height;

      // Compress and resize the image
      List<int> compressedBytes = await FlutterImageCompress.compressWithList(
        Uint8List.fromList(originalBytes),
        minHeight: (originalHeight * scaleFactor).toInt(),
        minWidth: (originalWidth * scaleFactor).toInt(),
        quality: 90, // Adjust the quality as needed
      );

      // Add the resized image to the cache
      _cacheManager.addToCache(cacheKey, Uint8List.fromList(compressedBytes));

      return compressedBytes;
    } catch (e) {
      print('Error resizing image: $e');
      throw e;
    }
  }

  Future<XFile> saveResizedImage(List<int> imageBytes) async {
    File resizedFile = File('${(await getTemporaryDirectory()).path}/resized_image.jpg');
    await resizedFile.writeAsBytes(imageBytes);
    return XFile(resizedFile.path);
  }
}