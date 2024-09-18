import 'package:flutter/material.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/domain_layer/entities/nip_51_list.dart';
import 'package:ndk/event_filter.dart';
import 'package:ndk/shared/nips/nip25/reactions.dart';

class FilterProvider extends ChangeNotifier implements EventFilter {
  static FilterProvider? _instance;

  Nip51List? _muteList;
  List<String>? _mutedTags;

  TrieTree? trieTree;

  set muteList(Nip51List? list) {
    _muteList = list;
    _mutedTags = list!=null? list.hashtags.map((element) => element.value.trim().toLowerCase()).toList() : [];
    List<String> words = _muteList!=null? _muteList!.words.map((e) => e.value).toList():[];
    List<List<int>> treeWords = List.generate(words.length, (index) {
      var word = words[index];
      return word.codeUnits;
    });
    trieTree = buildTrieTree(treeWords, null);
  }

  int get muteListCount => _muteList!=null? _muteList!.elements.length : 0;

  static FilterProvider getInstance() {
    _instance ??= FilterProvider();
    return _instance!;
  }

  bool hasMutedWord(String targetStr) {
    return trieTree!=null && trieTree!.check(targetStr.toLowerCase());
  }

  @override
  bool filter(Nip01Event event) {
    return (event.kind==Metadata.KIND || !isMutedPubKey(event.pubKey)) && (event.kind==Reaction.KIND || !hasMutedWord(event.content)) && !hasMutedHashtag(event);
  }

  bool isMutedPubKey(String pubKey) {
    return _muteList!=null && _muteList!.pubKeys.any((element) => element.value==pubKey);
  }

  bool hasMutedHashtag(Nip01Event event) {
    List<String> tTags = event.tTags;
    return tTags.isNotEmpty && _mutedTags!=null && tTags.any((tag) => _mutedTags!.contains(tag));
  }
}

TrieTree buildTrieTree(List<List<int>> words, List<int>? skips) {
  skips ??= [];

  var tree = TrieTree(TrieNode())..skips = skips;

  for (var word in words) {
    tree.root.insertWord(word, skips);
  }

  return tree;
}

class TrieTree {
  TrieNode root;
  List<int>? skips;

  TrieTree(this.root);

  bool check(String targetStr) {
    var target = targetStr.codeUnits;
    var index = 0;
    var length = target.length;
    for (; index < length;) {
      var current = root;
      for (var i = index; i < length; i++) {
        var char = target[i];
        var tmpNode = current.find(char);
        if (tmpNode != null) {
          current = tmpNode;
          if (current.done) {
            return true;
          }
        } else {
          break;
        }
      }
      index++;
    }

    return false;
  }
}

class TrieNode {
  Map<int, TrieNode> children = {};
  bool done;

  TrieNode({
    this.done = false,
  });

  void insertWord(List<int> word, List<int> skips) {
    var current = this;
    for (var char in word) {
      current = current.findOrCreate(char, skips);
    }
    current.done = true;
  }

  TrieNode? find(int char) {
    return children[char];
  }

  TrieNode findOrCreate(int char, List<int> skips) {
    var child = children[char];
    if (child == null) {
      child = TrieNode();

      children[char] = child;
      for (var skip in skips) {
        children[skip] = child;
      }
    }
    return child;
  }
}

