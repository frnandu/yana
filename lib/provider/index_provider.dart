import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../config/app_features.dart';
import '../utils/index_taps.dart';

class IndexProvider extends ChangeNotifier {
  int _currentTap = IndexTaps.FOLLOW;

  int get currentTap => _currentTap;

  IndexProvider({int? indexTap}) {
    if (indexTap != null) {
      _currentTap = indexTap;
    }
  }

  void setCurrentTap(int v) {
    if (!AppFeatures.enableSearch && v == IndexTaps.SEARCH) {
      return;
    }
    if (!AppFeatures.enableDm && v == IndexTaps.DM) {
      return;
    }
    _currentTap = v;
    notifyListeners();
  }

  TabController? _followTabController;

  void setFollowTabController(TabController? followTabController) {
    _followTabController = followTabController;
  }

  ScrollController? _followPostsScrollController;

  void setFollowPostsScrollController(
      ScrollController? followPostsScrollController) {
    _followPostsScrollController = followPostsScrollController;
    followPostsScrollController?.addListener(() {
      scrollCallback?.call(followPostsScrollController.position.userScrollDirection);
    });
  }

  ScrollController? _followScrollController;

  void setFollowScrollController(ScrollController? followScrollController) {
    _followScrollController = followScrollController;
    followScrollController?.addListener(() {
      scrollCallback?.call(followScrollController.position.userScrollDirection);
    });
  }

  ScrollController? _mentionedScrollController;

  void setMentionedScrollController(
      ScrollController? mentionedScrollController) {
    _mentionedScrollController = mentionedScrollController;
    mentionedScrollController?.addListener(() {
      scrollCallback?.call(mentionedScrollController.position.userScrollDirection);
    });
  }

  void followScrollToTop() {
    if (_followTabController != null) {
      if (_followTabController!.index == 0 &&
          _followPostsScrollController != null) {
        _followPostsScrollController!.animateTo(0, curve: Curves.ease, duration: const Duration(seconds: 1));
      } else if (_followTabController!.index == 1 &&
          _followScrollController != null) {
        _followScrollController!.animateTo(0, curve: Curves.ease, duration: const Duration(seconds: 1));
      } else if (_followTabController!.index == 2 &&
          _mentionedScrollController != null) {
        _mentionedScrollController!.animateTo(0, curve: Curves.ease, duration: const Duration(seconds: 1));
      }
    }
  }

  ScrollController? _eventScrollController;

  void setEventScrollController(ScrollController? eventScrollController) {
    _eventScrollController = eventScrollController;
    eventScrollController?.addListener(() {
      scrollCallback?.call(eventScrollController!.position.userScrollDirection);
    });
  }

  ScrollController? get eventScrollController => _eventScrollController;
  ScrollController? get followScrollController => _followScrollController;


  ScrollDirectionCallback? scrollCallback;

  void addScrollListener(ScrollDirectionCallback listener) {
    scrollCallback = listener;
  }
}
typedef ScrollDirectionCallback = void Function(ScrollDirection direction);
