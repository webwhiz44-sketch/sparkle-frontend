class PollOptionModel {
  final int id;
  final String optionText;
  final int voteCount;
  final double percentage;

  PollOptionModel({
    required this.id,
    required this.optionText,
    required this.voteCount,
    required this.percentage,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'],
      optionText: json['optionText'],
      voteCount: json['voteCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class PollModel {
  final int id;
  final String question;
  final int totalVotes;
  final bool votedByMe;
  final int? myVotedOptionId;
  final List<PollOptionModel> options;

  PollModel({
    required this.id,
    required this.question,
    required this.totalVotes,
    required this.votedByMe,
    this.myVotedOptionId,
    required this.options,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'],
      question: json['question'],
      totalVotes: json['totalVotes'] ?? 0,
      votedByMe: json['votedByMe'] ?? false,
      myVotedOptionId: json['myVotedOptionId'],
      options: (json['options'] as List? ?? [])
          .map((o) => PollOptionModel.fromJson(o))
          .toList(),
    );
  }

  PollModel copyWith({
    bool? votedByMe,
    int? myVotedOptionId,
    int? totalVotes,
    List<PollOptionModel>? options,
  }) {
    return PollModel(
      id: id,
      question: question,
      totalVotes: totalVotes ?? this.totalVotes,
      votedByMe: votedByMe ?? this.votedByMe,
      myVotedOptionId: myVotedOptionId ?? this.myVotedOptionId,
      options: options ?? this.options,
    );
  }
}
