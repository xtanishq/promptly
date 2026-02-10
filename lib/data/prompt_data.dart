import 'prompt_model.dart';

final List<Map<String, dynamic>> initialPromptData = [
  {
    "id": "1",
    "category": "premium",
    "image_url": "https://picsum.photos/seed/1/600/800", // Portrait
    "prompt":
        "Cyberpunk street in the rain, 8k, neon lights, reflections, high contrast [Cinematic]",
    "gen_count": "4.2k",
  },
  {
    "id": "2",
    "category": "premium",
    "image_url": "https://picsum.photos/seed/2/600/600", // Square
    "prompt":
        "Fluid color explosion, abstract digital art, swirling patterns, vibrant colors",
    "gen_count": "1.5k",
  },
  {
    "id": "3",
    "category": "premium",
    "image_url": "https://picsum.photos/seed/3/600/900", // Tall
    "prompt":
        "Futuristic portrait of a woman with bioluminescent makeup, highly detailed eyes",
    "gen_count": "8.9k",
  },
  {
    "id": "4",
    "category": "Landscape",
    "image_url": "https://picsum.photos/seed/4/600/400", // Wide
    "prompt":
        "Alien landscape, purple sky, floating islands, misty atmosphere, 4k render",
    "gen_count": "2.1k",
  },
  {
    "id": "5",
    "category": "Sci-Fi",
    "image_url": "https://picsum.photos/seed/5/600/750", // Custom
    "prompt":
        "Interior of a spaceship, sleek white design, holographic displays, view of a planet",
    "gen_count": "3.4k",
  },
  {
    "id": "6",
    "category": "Anime",
    "image_url": "https://picsum.photos/seed/6/600/1000", // Extra Tall
    "prompt":
        "Anime style warrior, katana, cherry blossoms falling, intense gaze, sunset",
    "gen_count": "5.6k",
  },
];

List<Prompt> getPrompts() {
  return initialPromptData.map((e) => Prompt.fromJson(e)).toList();
}
