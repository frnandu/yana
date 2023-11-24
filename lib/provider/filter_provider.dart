import 'package:dart_ndk/event_filter.dart';
import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:dart_ndk/nips/nip51/nip51.dart';
import 'package:flutter/material.dart';
import 'package:yana/provider/data_util.dart';

import '../main.dart';
import '../utils/dirtywords_util.dart';

class FilterProvider extends ChangeNotifier implements EventFilter {
  static FilterProvider? _instance;

  List<String> dirtywordList = [];

  Nip51List? muteList;

  late TrieTree trieTree;

  int get muteListCount => muteList!=null? muteList!.elements.length : 0;

  static FilterProvider getInstance() {
    if (_instance == null) {
      _instance = FilterProvider();

      var dirtywordList =
          sharedPreferences.getStringList(DataKey.DIRTYWORD_LIST);
      if (dirtywordList != null && dirtywordList.isNotEmpty) {
        _instance!.dirtywordList = dirtywordList;
      }

      var wordsLength = _instance!.dirtywordList.length;
      List<List<int>> words = List.generate(wordsLength, (index) {
        var word = _instance!.dirtywordList[index];
        return word.codeUnits;
      });
      _instance!.trieTree = buildTrieTree(words, null);
    }

    return _instance!;
  }

  bool checkDirtyword(String targetStr) {
    if (dirtywordList.isEmpty) {
      return false;
    }
    return trieTree.check(targetStr.toLowerCase());
  }

  void removeDirtyword(String word) {
    dirtywordList.remove(word);
    var wordsLength = dirtywordList.length;
    List<List<int>> words = List.generate(wordsLength, (index) {
      var word = _instance!.dirtywordList[index];
      return word.codeUnits;
    });
    trieTree = buildTrieTree(words, null);

    _updateDirtyword();
  }

  void addDirtyword(String word) {
    dirtywordList.add(word);
    trieTree.root.insertWord(word.toLowerCase().codeUnits, []);

    _updateDirtyword();
  }

  void _updateDirtyword() {
    sharedPreferences.setStringList(DataKey.DIRTYWORD_LIST, dirtywordList);
    notifyListeners();
  }

  @override
  bool filter(Nip01Event event) {
    return (muteList==null || !muteList!.elements.any((element) => element.tag == Nip51List.PUB_KEY && element.value == event.pubKey)) && !checkDirtyword(event.content);
  }

  isMutedPubKey(String pubKey) {
    return muteList!=null && muteList!.elements.any((element) => element.tag == Nip51List.PUB_KEY && element.value==pubKey);
  }
}
