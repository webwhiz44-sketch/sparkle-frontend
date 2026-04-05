import '../models/poll_model.dart';
import 'api_client.dart';

class PollService {
  static Future<PollModel> vote(int pollId, int optionId) async {
    final response = await ApiClient.post(
      '/api/polls/$pollId/vote',
      {'optionId': optionId},
    );
    return PollModel.fromJson(ApiClient.parseResponse(response));
  }
}
