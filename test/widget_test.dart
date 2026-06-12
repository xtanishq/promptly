import 'package:flutter_test/flutter_test.dart';
import 'package:promptly/data/prompt_model.dart';

void main() {
  test('Prompt JSON round-trip preserves key fields', () {
    final prompt = Prompt.fromJson(const {
      'id': '42',
      'category': 'Sci-Fi',
      'image_url': 'https://example.com/image.png',
      'prompt': 'Generate a cinematic robot portrait',
      'gen_count': '9.1k',
    });

    expect(prompt.id, '42');
    expect(prompt.category, 'Sci-Fi');
    expect(prompt.imageUrl, 'https://example.com/image.png');
    expect(prompt.promptText, 'Generate a cinematic robot portrait');
    expect(prompt.genCount, '9.1k');
    expect(prompt.toJson()['prompt'], 'Generate a cinematic robot portrait');
  });
}
