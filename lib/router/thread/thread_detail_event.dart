import 'package:ndk/domain_layer/entities/nip_01_event.dart';

class ThreadDetailEvent {
  Nip01Event event;

  int totalLevelNum = 1;

  int currentLevel = 1;

  int handleTotalLevelNum(int preLevel) {
    currentLevel = preLevel + 1;

    if (subItems.isEmpty) {
      return 1;
    }
    var maxSubLevelNum = 0;
    for (var subItem in subItems) {
      var subLevelNum = subItem.handleTotalLevelNum(currentLevel);
      if (subLevelNum > maxSubLevelNum) {
        maxSubLevelNum = subLevelNum;
      }
    }

    totalLevelNum = maxSubLevelNum + 1;
    return totalLevelNum;
  }

  List<ThreadDetailEvent> subItems = [];

  ThreadDetailEvent({required this.event});
}
