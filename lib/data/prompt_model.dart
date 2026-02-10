class Prompt {
  final String id;
  final String category;
  final String imageUrl;
  final String promptText;
  final String genCount;

  Prompt({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.promptText,
    required this.genCount,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      promptText: json['prompt'] as String,
      genCount: json['gen_count'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'image_url': imageUrl,
      'prompt': promptText,
      'gen_count': genCount,
    };
  }
}
