enum PollType { Single, Multiple }

class PollModel {
  final String uuid;
  final String question;
  final PollType type;
  final bool can_add_option;
  final List<int> selected_options;
  final List<PollOption> options;
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
    List<int> selected_options = [];
    for (var i = 0; i < json['selected_option'].length; i++) {
      selected_options.add(json['selected_option'][i]);
    }

    return PollModel(
      uuid: json['uuid'],
      question: json['question'],
      type: json['type'] == 'Single' ? PollType.Single : PollType.Multiple,
      can_add_option: json['can_add_option'],
      selected_options: selected_options,
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
