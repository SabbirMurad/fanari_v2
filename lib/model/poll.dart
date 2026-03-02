enum PollType { single, multiple }

class _PollOption {
  final String text;
  final int vote;

  const _PollOption({required this.text, required this.vote});

  factory _PollOption.fromJson(Map<String, dynamic> json) {
    return _PollOption(text: json['text'], vote: json['vote']);
  }

  static List<_PollOption> fromJsonList(List<dynamic> json) {
    return json.map((item) => _PollOption.fromJson(item)).toList();
  }
}

class PollModel {
  final String uuid;
  final String question;
  final PollType type;
  final bool can_add_option;
  final List<int> selected_options;
  final List<_PollOption> options;
  final int total_vote;

  const PollModel({
    required this.uuid,
    required this.question,
    required this.type,
    required this.can_add_option,
    required this.selected_options,
    required this.options,
    required this.total_vote,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final selected_options = List<int>.from(json['selected_option']);

    return PollModel(
      uuid: json['uuid'],
      question: json['question'],
      type: json['type'] == 'Single' ? PollType.single : PollType.multiple,
      can_add_option: json['can_add_option'],
      selected_options: selected_options,
      options: _PollOption.fromJsonList(json['options']),
      total_vote: json['total_vote'],
    );
  }
}
