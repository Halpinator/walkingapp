class Submission {
  final String title;
  final String author;
  final String url;
  final String description;

  Submission({
    required this.title,
    required this.author,
    required this.url,
    required this.description,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      title: json['title'],
      author: json['author'],
      url: json['url'],
      description: json['description'],
    );
  }
}
