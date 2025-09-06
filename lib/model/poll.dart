enum PollType { single, multiple }

class PollModel {
  final String question;
  final PollType type;
  final bool can_add_option;
  final List<int> selected_options;
  final List<PollOption> options;
  final int total_vote;

  const PollModel({
    required this.question,
    required this.type,
    required this.can_add_option,
    required this.selected_options,
    required this.options,
    required this.total_vote,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      question: json['question'],
      type: json['type'],
      can_add_option: json['can_add_option'],
      selected_options: json['selected_option'],
      options: PollOption.fromJsonList(json['options']),
      total_vote: json['total_vote'],
    );
  }
}

class PollOption {
  final String text;
  final int vote;

  const PollOption({required this.text, required this.vote});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(text: json['text'], vote: json['vote']);
  }

  static List<PollOption> fromJsonList(List<dynamic> json) {
    return json.map((item) => PollOption.fromJson(item)).toList();
  }
}
