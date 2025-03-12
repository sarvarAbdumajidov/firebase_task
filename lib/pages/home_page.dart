import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:firebase_task/pages/create_page.dart';
import 'package:firebase_task/service/auth_service.dart';
import 'package:firebase_task/service/rtdb_service.dart';
import 'package:video_player/video_player.dart';
import '../model/post_model.dart';

class HomePage extends StatefulWidget {
  static const String id = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [];
  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController?> _chewieControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _apiPostList());
  }

  Future<void> _apiPostList() async {
    var list = await RTDBService.getPosts();
    setState(() {
      posts = list;
    });
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    _disposeControllers();

    for (var post in posts) {
      if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(post.videoUrl!),videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        await controller.initialize();

        final chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: false,
          aspectRatio: controller.value.aspectRatio,
          errorBuilder: (context, errorMessage) => Center(child: Text("Xatolik yuz berdi: $errorMessage")),
        );

        setState(() {
          _videoControllers.add(controller);
          _chewieControllers.add(chewieController);
        });
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    for (var chewieController in _chewieControllers) {
      chewieController?.dispose();
    }
    _videoControllers.clear();
    _chewieControllers.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Future<void> _callCreatePage() async {
    Map? result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreatePage()),
    );
    if (result != null && result.containsKey('data')) {
      _apiPostList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: PopupMenuButton(
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == "Logout") {
                AuthService.signOutUser(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, color: Colors.deepPurpleAccent),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
          title: Text('Home', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepOrange,
        ),
        body: Center(
          child: posts.isEmpty
              ? CircularProgressIndicator()
              : Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                if (index >= _videoControllers.length || index >= _chewieControllers.length) {
                  return SizedBox.shrink();
                }
                return _itemsOfVideoPhoto(
                  posts[index].textVideo!,
                  posts[index].textImage!,
                  posts[index].imageUrl!,
                  _videoControllers[index],
                  _chewieControllers[index],
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: _callCreatePage,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

Widget _itemsOfVideoPhoto(
    String textVideo,
    String textPhoto,
    String imageUrl,
    VideoPlayerController videoController,
    ChewieController? chewieController,
    ) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.deepOrange,
      ),
      child: Column(
        children: [
          Text(textVideo, style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: chewieController != null
                ? Chewie(controller: chewieController)
                : Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: 20),
          Text(textPhoto, style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
          ),
        ],
      ),
    ),
  );
}
