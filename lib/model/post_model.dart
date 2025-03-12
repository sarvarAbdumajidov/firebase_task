class Post {
  String? imageUrl;
  String? videoUrl;
  String? textImage;
  String? textVideo;

  Post({this.imageUrl, this.videoUrl, this.textImage, this.textVideo});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      imageUrl: json['imageUrl'] ?? "",
      videoUrl: json['videoUrl'] ?? "",
      textImage: json['textImage'] ?? "",
      textVideo: json['textVideo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "videoUrl": videoUrl,
        "textImage": textImage,
        "textVideo": textVideo,
      };
}
