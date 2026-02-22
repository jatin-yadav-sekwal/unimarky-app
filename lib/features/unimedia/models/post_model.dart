// Unimedia data models — mirrors web campus/types.ts

class PostAuthor {
  final String id;
  final String fullName;
  final String? idCardUrl;
  final String role;

  PostAuthor({required this.id, required this.fullName, this.idCardUrl, this.role = 'normal'});

  factory PostAuthor.fromJson(Map<String, dynamic> json) => PostAuthor(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName'] ?? '',
    idCardUrl: json['idCardUrl'],
    role: json['role'] ?? 'normal',
  );
}

class Post {
  final String id;
  final String authorId;
  final String type; // "post" | "event" | "announcement"
  final String? title;
  final String content;
  final String? imageUrl;
  final String? eventDate;
  final String? hostedBy;
  int likesCount;
  int commentsCount;
  final int sharesCount;
  final String? universityName;
  final String createdAt;
  final String updatedAt;
  bool isLiked;
  final PostAuthor author;

  Post({
    required this.id, required this.authorId, this.type = 'post',
    this.title, required this.content, this.imageUrl, this.eventDate,
    this.hostedBy, this.likesCount = 0, this.commentsCount = 0,
    this.sharesCount = 0, this.universityName, required this.createdAt,
    required this.updatedAt, this.isLiked = false, required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id']?.toString() ?? '',
    authorId: json['authorId']?.toString() ?? '',
    type: json['type'] ?? 'post',
    title: json['title'],
    content: json['content'] ?? '',
    imageUrl: json['imageUrl'],
    eventDate: json['eventDate'],
    hostedBy: json['hostedBy'],
    likesCount: json['likesCount'] ?? 0,
    commentsCount: json['commentsCount'] ?? 0,
    sharesCount: json['sharesCount'] ?? 0,
    universityName: json['universityName'],
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    isLiked: json['isLiked'] == true,
    author: PostAuthor.fromJson(json['author'] ?? {}),
  );
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String createdAt;
  final PostAuthor user;

  Comment({
    required this.id, required this.postId, required this.userId,
    required this.content, required this.createdAt, required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id']?.toString() ?? '',
    postId: json['postId']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    content: json['content'] ?? '',
    createdAt: json['createdAt'] ?? '',
    user: PostAuthor.fromJson(json['user'] ?? {}),
  );
}

const feedTabs = [
  {'id': 'all', 'label': 'All Feed'},
  {'id': 'post', 'label': 'Posts'},
  {'id': 'event', 'label': 'Events'},
  {'id': 'announcement', 'label': 'News'},
];
