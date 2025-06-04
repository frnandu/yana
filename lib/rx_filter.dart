import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ndk/ndk.dart';
import 'package:rxdart/rxdart.dart';

import 'main.dart' show ndk;

/// Reactive filter which builds the widget with a snapshot of the data
class RxFilter<T> extends StatefulWidget {
  final List<Filter> filters;
  final bool leaveOpen;
  final Widget Function(BuildContext, List<T>?) builder;
  final T Function(Nip01Event)? mapper;
  final List<String>? relays;

  const RxFilter(
    Key? key, {
    required this.filters,
    this.leaveOpen = false,
    required this.builder,
    this.mapper,
    this.relays,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RxFilter<T>();
}

class _RxFilter<T> extends State<RxFilter<T>> {
  late final RxFilterState<T> _state;

  @override
  void initState() {
    _state = RxFilterState<T>(
      filters: widget.filters,
      leaveOpen: widget.leaveOpen,
      mapper: widget.mapper,
      relays: widget.relays,
    );
    /* send spam into chat
    if (widget.key is ValueKey) {
      final vk = (widget.key as ValueKey).value as String;
      if (vk.startsWith("stream:chat:")) {
        Timer.periodic(Duration(seconds: 1), (_) {
          final spam = Nip01Event(
            pubKey:
                "63fe6318dc58583cfe16810f86dd09e18bfd76aabc24a0081ce2856f330504ed",
            kind: 1311,
            tags: [
              ["a", vk.split(":").last],
            ],
            content: "SPAM ${DateTime.now()}",
          );
          _state.insertEvent(spam);
        });
      }
    }*/
    super.initState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, state, _) {
        return widget.builder(context, state);
      },
    );
  }
}

class RxFilterState<T> extends ChangeNotifier
    implements ValueListenable<List<T>?> {
  final List<Filter> filters;
  final bool leaveOpen;
  final T Function(Nip01Event)? mapper;
  final List<String>? relays;
  HashMap<String, (int, T)>? _events;
  late final NdkResponse _response;
  late final StreamSubscription _listener;

  RxFilterState({
    required this.filters,
    this.leaveOpen = false,
    this.mapper,
    this.relays,
  }) {
    developer.log("RX:SEDNING $filters");
    _response = ndk.requests.subscription(
      filters: filters,
      explicitRelays: relays,
      cacheWrite: true,
    );
    if (!leaveOpen) {
      _response.future.then((_) {
        developer.log("RX:CLOSING $filters");
        ndk.requests.closeSubscription(_response.requestId);
      });
    }
    _listener = _response.stream
        .bufferTime(const Duration(milliseconds: 500))
        .where((events) => events.isNotEmpty)
        .handleError((e) {
          developer.log("RX:ERROR $e");
        })
        .listen((events) {
          developer.log("RX:GOT ${events.length} events for $filters");
          var didUpdate = false;
          for (final ev in events) {
            if (_replaceInto(ev)) {
              didUpdate = true;
            }
          }
          if (didUpdate) {
            notifyListeners();
          }
        });
  }

  void insertEvent(Nip01Event ev) {
    if (_replaceInto(ev)) {
      notifyListeners();
    }
  }

  bool _replaceInto(Nip01Event ev) {
    final evKey = _eventKey(ev);
    _events ??= HashMap();
    final existing = _events![evKey];
    if (existing == null || existing.$1 < ev.createdAt) {
      _events![evKey] = (ev.createdAt, mapper != null ? mapper!(ev) : ev as T);
      return true;
    }
    return false;
  }

  String _eventKey(Nip01Event ev) {
    if ([0, 3].contains(ev.kind) || (ev.kind >= 10000 && ev.kind < 20000)) {
      return "${ev.kind}:${ev.pubKey}";
    } else if (ev.kind >= 30000 && ev.kind < 40000) {
      return "${ev.kind}:${ev.pubKey}:${ev.getDtag()}";
    } else {
      return ev.id;
    }
  }

  @override
  List<T>? get value =>
      _events != null ? List<T>.from(_events!.values.map((v) => v.$2)) : null;

  @override
  void dispose() {
    developer.log("RX:CLOSING $filters");
    _listener.cancel();
    ndk.requests.closeSubscription(_response.requestId);
    super.dispose();
  }
}

/// An async filter loader into [RxFilter]
class RxFutureFilter<T> extends StatelessWidget {
  final Future<List<Filter>> Function() filterBuilder;
  final bool leaveOpen;
  final Widget Function(BuildContext, List<T>?) builder;
  final Widget? loadingWidget;
  final T Function(Nip01Event)? mapper;

  const RxFutureFilter(
    Key key, {
    required this.filterBuilder,
    required this.builder,
    this.mapper,
    this.leaveOpen = true,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Filter>>(
      future: filterBuilder(),
      builder: (ctx, data) {
        if (data.hasData) {
          return RxFilter<T>(
            super.key!,
            filters: data.data!,
            mapper: mapper,
            builder: builder,
          );
        } else {
          return loadingWidget ?? SizedBox.shrink();
        }
      },
    );
  }
}
