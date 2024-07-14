class Post {
  final String title;
  final String author;
  final String url;
  final String description;

  Post({
    required this.title,
    required this.author,
    required this.url,
    required this.description,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'],
      author: json['author'],
      url: json['url'],
      description: json['description'],
    );
  }
}
