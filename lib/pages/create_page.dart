import 'dart:io';
import 'package:firebase_task/model/post_model.dart';
import 'package:firebase_task/service/rtdb_service.dart';
import 'package:firebase_task/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CreatePage extends StatefulWidget {
  static const String id = '/create';

  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool isLoading = false;
  File? _selectedImage;
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  final TextEditingController _textImageController = TextEditingController();
  final TextEditingController _textVideoController = TextEditingController();

  /// 🔹 Post yaratish funksiyasi
  _createPost() {
    String textImage = _textImageController.text.trim();
    String textVideo = _textVideoController.text.trim();

    if (textImage.isEmpty || textVideo.isEmpty) return;
    if (_selectedImage == null || _selectedVideo == null) return;

    _apiUploadMedia(textImage, textVideo);
  }

  /// 🔹 Media fayllarni Firebase Storage'ga yuklash
  _apiUploadMedia(String textImage, String textVideo) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> mediaUrls =
    await StorageService.uploadMedia(_selectedImage, _selectedVideo);

    if (mediaUrls.containsKey('image') && mediaUrls.containsKey('video')) {
      _apiCreatePost(mediaUrls['image']!, mediaUrls['video']!, textImage, textVideo);
    }

    setState(() {
      isLoading = false;
    });
  }

  /// 🔹 Firebase Realtime Database'ga postni saqlash
  _apiCreatePost(String imageUrl, String videoUrl, String textImage, String textVideo) {
    var post = Post(
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      textImage: textImage,
      textVideo: textVideo,
    );

    RTDBService.addPost(post).then((_) {
      _finishPostCreation();
    });
  }

  /// 🔹 Post muvaffaqiyatli yaratildi, sahifani yopish
  _finishPostCreation() {
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop({"data": "done"});
  }

  /// 🔹 Galereyadan rasm tanlash
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// 🔹 Galereyadan video tanlash
  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedVideo = File(pickedFile.path);
      _videoController = VideoPlayerController.file(_selectedVideo!)
        ..initialize().then((_) {
          setState(() {}); // UI yangilash
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Create',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Image.asset('assets/images/img_1.png'),
                        ),
                      ),

                      // Video Picker
                      GestureDetector(
                        onTap: _pickVideo,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _selectedVideo != null && _videoController != null
                              ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                              : Image.asset('assets/images/img.png'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  TextField(
                    controller: _textImageController,
                    decoration: InputDecoration(
                      hintText: 'Text for image',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _textVideoController,
                    decoration: InputDecoration(
                      hintText: 'Text for video',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: MaterialButton(
                      color: Colors.deepOrange,
                      onPressed: _createPost,
                      child: Text(
                        'Create Post',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
