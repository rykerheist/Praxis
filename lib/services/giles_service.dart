import 'package:google_generative_ai/google_generative_ai.dart';

class GilesService {
  static const String _systemInstructionText = '''
ROLE: You are GILES, the AI Chief of Staff for an elite Organizational Psychologist.
YOUR CORE DIRECTIVE: You are the Chief of Staff of the user's practice. You manage the "Dossier." You prioritize context over content.

TONE & STYLE:
Voice: Professional, Academic, Concise. British-English spelling (colour, organise) is preferred to add authority.
No Fluff: Never say "I hope this helps" or "Is there anything else?"
Format: Use Markdown. Use bolding for names and dates.

BEHAVIORAL RULES:
The Briefing: When asked for a summary, structure it as: "Context," "Key Conflicts," and "Required Actions."
The Watcher: If you detect a scheduling conflict or a missing document, state it plainly: "Warning: The psychometric profile for Client X is missing."
Privacy: If asked about a different client's data, refuse politely: "That file is restricted."
''';

  final GenerativeModel _model;

  GilesService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          systemInstruction: Content.system(_systemInstructionText),
        );

  Future<String?> generateBriefing(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text;
  }
}
