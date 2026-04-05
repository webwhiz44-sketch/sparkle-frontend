import 'package:flutter/material.dart';
import '../models/poll_model.dart';
import '../services/poll_service.dart';
import '../services/api_client.dart';

class PollWidget extends StatefulWidget {
  final PollModel poll;
  final void Function(PollModel updated) onVoted;

  const PollWidget({super.key, required this.poll, required this.onVoted});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  bool _isVoting = false;
  late PollModel _poll;

  @override
  void initState() {
    super.initState();
    _poll = widget.poll;
  }

  @override
  void didUpdateWidget(PollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _poll = widget.poll;
  }

  Future<void> _vote(int optionId) async {
    if (_poll.votedByMe || _isVoting) return;
    setState(() => _isVoting = true);

    // Optimistic update — compute percentages locally
    final newTotal = _poll.totalVotes + 1;
    final updatedOptions = _poll.options.map((o) {
      final newCount = o.id == optionId ? o.voteCount + 1 : o.voteCount;
      return PollOptionModel(
        id: o.id,
        optionText: o.optionText,
        voteCount: newCount,
        percentage: newTotal > 0 ? (newCount / newTotal) * 100 : 0,
      );
    }).toList();

    final optimistic = _poll.copyWith(
      votedByMe: true,
      myVotedOptionId: optionId,
      totalVotes: newTotal,
      options: updatedOptions,
    );
    setState(() => _poll = optimistic);

    try {
      final updated = await PollService.vote(_poll.id, optionId);
      if (mounted) {
        setState(() => _poll = updated);
        widget.onVoted(updated);
      }
    } on ApiException {
      // Revert on failure
      if (mounted) setState(() => _poll = widget.poll);
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 15, color: Color(0xFFBE1373)),
              const SizedBox(width: 5),
              const Text('POLL',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFBE1373),
                      letterSpacing: 1.5)),
              const Spacer(),
              Text('${_poll.totalVotes} votes',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFAAAAAA))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _poll.question,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.4),
          ),
          const SizedBox(height: 10),
          ..._poll.options.map((option) => _buildOption(option)),
        ],
      ),
    );
  }

  Widget _buildOption(PollOptionModel option) {
    final isVoted = _poll.myVotedOptionId == option.id;
    final showResults = _poll.votedByMe;
    final pct = showResults ? option.percentage : 0.0;

    return GestureDetector(
      onTap: showResults ? null : () => _vote(option.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            // Background fill (vote bar)
            if (showResults)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isVoted
                          ? const Color(0xFFBE1373).withOpacity(0.15)
                          : const Color(0xFF000000).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            // Option row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isVoted
                      ? const Color(0xFFBE1373)
                      : const Color(0xFFDDDDDD),
                  width: isVoted ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (showResults)
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isVoted
                            ? const Color(0xFFBE1373)
                            : Colors.transparent,
                        border: Border.all(
                          color: isVoted
                              ? const Color(0xFFBE1373)
                              : const Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                      ),
                      child: isVoted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 10)
                          : null,
                    )
                  else
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFCCCCCC), width: 1.5),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isVoted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isVoted
                            ? const Color(0xFFBE1373)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ),
                  if (showResults)
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isVoted
                            ? const Color(0xFFBE1373)
                            : const Color(0xFF888888),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
