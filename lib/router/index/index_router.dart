import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:provider/provider.dart';
import 'package:yana/provider/dm_provider.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/provider/pc_router_fake_provider.dart';
import 'package:yana/router/follow/notifications_router.dart';
import 'package:yana/ui/cust_state.dart';
import 'package:yana/ui/pc_router_fake.dart';
import 'package:yana/utils/base_consts.dart';
import 'package:yana/utils/index_taps.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/event_mem_box.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../provider/data_util.dart';
import '../../provider/follow_event_provider.dart';
import '../../provider/follow_new_event_provider.dart';
import '../../provider/index_provider.dart';
import '../../provider/setting_provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/auth_util.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../config/app_features.dart';
import '../dm/dm_router.dart';
import '../edit/editor_router.dart';
import '../follow/follow_index_router.dart';
import '../login/login_router.dart';
import '../search/search_router.dart';
import '../wallet/wallet_router.dart';
import 'index_app_bar.dart';
import 'index_bottom_bar.dart';
import 'index_drawer_content.dart';

class IndexRouter extends StatefulWidget {
  Function reload;

  IndexRouter({super.key, required this.reload});

  @override
  State<StatefulWidget> createState() {
    return _IndexRouter();
  }
}

class _IndexRouter extends CustState<IndexRouter>
    with TickerProviderStateMixin {
  static double DRAWER_WIDTH = 300;

  late TabController followTabController;

  late TabController dmTabController;

  bool _scrollingDown = false;

  bool _creatingAccount = false;

  @override
  void initState() {
    super.initState();
    int followInitTab = 0;
    int globalsInitTab = 0;

    if (settingProvider.defaultTab != null) {
      if (settingProvider.defaultIndex == 1) {
        globalsInitTab = settingProvider.defaultTab!;
      } else {
        followInitTab = settingProvider.defaultTab!;
      }
    }

    followTabController =
        TabController(initialIndex: followInitTab, length: 3, vsync: this);
    dmTabController = TabController(length: 3, vsync: this);
  }

  // @override
  void onProtocolUrlReceived(String url) async {
    // String log = 'Url received: $url)';
    // print(log);
    if (StringUtil.isNotBlank(url)) {
      if (url.startsWith("yana://?value=")) {
        Uri uri = Uri.parse(url);
        String? nwc = uri.queryParameters["value"];

        if (nwc != null && nwc.startsWith(NwcProvider.NWC_PROTOCOL_PREFIX)) {
          await nwcProvider?.connect(nwc, onConnect: (lud16) async {
            await metadataProvider.updateLud16IfEmpty(lud16);
          });
          bool canPop = Navigator.canPop(context);
          // var route = ModalRoute.of(context);
          // if (route != null && route!.settings.name != null && route!.settings.name! == RouterPath.NWC) {
          if (canPop) {
            context.pop();
          } else {
            context.push(RouterPath.WALLET);
          }
        }
      } else if (url.startsWith(NwcProvider.NWC_PROTOCOL_PREFIX)) {
        Future.delayed(const Duration(microseconds: 1), () async {
          bool newAccount = false;
          if (loggedUserSigner == null) {
            String priv = generatePrivateKey();
            sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
            sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);
            sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);
            if (AppFeatures.enableNotifications) {
              notificationsProvider?.clear();
              newNotificationsProvider?.clear();
            }
            if (AppFeatures.enableSocial) {
              followEventProvider?.clear();
              followNewEventProvider?.clear();
            }
            await settingProvider.addAndChangeKey(priv, true, false,
                updateUI: false);
            String publicKey = getPublicKey(priv);
            ndk.accounts.loginPrivateKey(pubkey: publicKey, privkey: priv);

            await initRelays(newKey: true);
            if (AppFeatures.enableSocial) {
              followEventProvider?.loadCachedFeed();
            }

            newAccount = true;
            firstLogin = true;
            // Set default tab based on available features
            if (AppFeatures.isWalletOnly) {
              indexProvider.setCurrentTap(IndexTaps.WALLET);
            } else if (AppFeatures.enableSocial) {
              indexProvider.setCurrentTap(IndexTaps.FOLLOW);
            } else if (AppFeatures.enableSearch) {
              indexProvider.setCurrentTap(IndexTaps.SEARCH);
            } else if (AppFeatures.enableDm) {
              indexProvider.setCurrentTap(IndexTaps.DM);
            } else if (AppFeatures.enableNotifications) {
              indexProvider.setCurrentTap(IndexTaps.NOTIFICATIONS);
            }
          }
          await nwcProvider?.connect(url, onConnect: (lud16) async {
            await metadataProvider.updateLud16IfEmpty(lud16);
          });
          bool canPop = Navigator.canPop(context);
          // var route = ModalRoute.of(context);
          // if (route != null && route!.settings.name != null && route!.settings.name! == RouterPath.NWC) {
          if (canPop) {
            context.pop();
          } else {
            context.go(newAccount ? RouterPath.INDEX : RouterPath.WALLET);
          }
        });
      } else if (url.startsWith("lightning:")) {
        context.push(RouterPath.WALLET_SEND, extra: url.split(":").last);
      } else if (url.startsWith("nostr:")) {
        RegExpMatch? match = Nip19.nip19regex.firstMatch(url);

        if (match != null) {
          var key = match.group(2)! + match.group(3)!;
          String? otherStr;

          if (Nip19.isPubkey(key)) {
            // inline
            // mention user
            if (key.length > Nip19.NPUB_LENGTH) {
              otherStr = key.substring(Nip19.NPUB_LENGTH);
              key = key.substring(0, Nip19.NPUB_LENGTH);
            }
            key = Nip19.decode(key);
            if (AppFeatures.enableSocial) {
              context.push(RouterPath.USER, extra: key);
            }
          } else if (Nip19.isNoteId(key)) {
            // block
            if (key.length > Nip19.NOTEID_LENGTH) {
              otherStr = key.substring(Nip19.NOTEID_LENGTH);
              key = key.substring(0, Nip19.NOTEID_LENGTH);
            }
            key = Nip19.decode(key);
            if (AppFeatures.enableSocial) {
              context.push(RouterPath.THREAD_DETAIL, extra: key);
            }
          } else if (NIP19Tlv.isNprofile(key)) {
            var nprofile = NIP19Tlv.decodeNprofile(key);
            if (nprofile != null) {
              // inline
              // mention user
              if (AppFeatures.enableSocial) {
                context.push(RouterPath.USER, extra: nprofile.pubkey);
              }
            }
          } else if (NIP19Tlv.isNrelay(key)) {
            var nrelay = NIP19Tlv.decodeNrelay(key);
            String? url = nrelay != null ? cleanRelayUrl(nrelay.addr) : null;
            if (url != null) {
              // inline
              Relay relay =
                  Relay(url: url, connectionSource: ConnectionSource.explicit);
              context.push(RouterPath.RELAY_INFO, extra: relay);
            }
          } else if (NIP19Tlv.isNevent(key)) {
            var nevent = NIP19Tlv.decodeNevent(key);
            if (nevent != null) {
              if (nevent.relays != null && nevent.relays!.isNotEmpty) {
                // TODO allowReconnectRelays is false, WTF?
                // await ndk.relays.reconnectRelays(nevent.relays!);
              }
              if (AppFeatures.enableSocial) {
                context.push(RouterPath.THREAD_DETAIL, extra: nevent.id);
              }
            }
          } else if (NIP19Tlv.isNaddr(key)) {
            var naddr = NIP19Tlv.decodeNaddr(key);
            if (naddr != null) {
              if (StringUtil.isNotBlank(naddr.id) &&
                  naddr.kind == Nip01Event.kTextNodeKind) {
                if (AppFeatures.enableSocial) {
                  context.push(RouterPath.THREAD_DETAIL, extra: naddr.id);
                }
              } else if (StringUtil.isNotBlank(naddr.author) &&
                  naddr.kind == Metadata.kKind) {
                if (AppFeatures.enableSocial) {
                  context.push(RouterPath.USER, extra: naddr.author);
                }
              }
            }
          }
        }
      }
    }
  }

  @override
  Future<void> onReady(BuildContext context) async {
    if (settingProvider.lockOpen == OpenStatus.OPEN && !unlock) {
      doAuth();
    } else {
      setState(() {
        unlock = true;
      });
    }
  }

  bool unlock = false;
  var badgeTextStyle =
      const TextStyle(color: Colors.white, fontFamily: "Roboto", fontSize: 2);

  @override
  Widget doBuild(BuildContext context) {
    var _settingProvider = Provider.of<SettingProvider>(context);

    mediaDataCache.update(context);
    var s = I18n.of(context);

    if (loggedUserSigner == null) {
      return LoginRouter(
        canGoBack: false,
      );
    }
    // var _followEventProvider = Provider.of<FollowEventProvider>(context);
    // var _followEventNewProvider = Provider.of<FollowNewEventProvider>(context);
    var _indexProvider = Provider.of<IndexProvider>(context);

    if (!unlock) {
      return const Scaffold();
    }

    _indexProvider.setFollowTabController(followTabController);

    scrollDirectionCallback(direction) {
      if (direction == ScrollDirection.idle && _scrollingDown) {
        _scrollingDown = false;
      }
      if (direction == ScrollDirection.reverse && !_scrollingDown) {
        setState(() {
          _scrollingDown = true;
        });
      }
      if (direction == ScrollDirection.forward && _scrollingDown) {
        setState(() {
          _scrollingDown = false;
        });
      }
    }

    _indexProvider.addScrollListener(scrollDirectionCallback);

    var themeData = Theme.of(context);
    var titleTextColor = themeData.appBarTheme.titleTextStyle!.color;
    var titleTextStyle = TextStyle(
      fontFamily: 'Geist',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: titleTextColor,
    );
    Color? indicatorColor = titleTextColor;
    if (PlatformUtil.isPC()) {
      indicatorColor = themeData.primaryColor;
    }

    dmTabController.addListener(() {
      setState(() {
        _scrollingDown = false;
      });
    });

    final double badgeSize = 6;

    Widget _badge(Text text, ThemeData themeData) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          text,
          Positioned(
            top: -2,
            right: -badgeSize / 1,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeData.primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    Widget? appBarCenter;
    if (AppFeatures.isWalletOnly) {
      // Don't show app bar center when only wallet is enabled
      appBarCenter = null;
    } else if (AppFeatures.enableSocial &&
        _indexProvider.currentTap == IndexTaps.FOLLOW) {
      appBarCenter = TabBar(
        indicatorColor: const Color(0xFF6A1B9A),
        indicatorWeight: 2,
        tabs: [
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Selector<FollowNewEventProvider, EventMemBox>(
              builder: (context, eventMemBox, child) {
                Text text = Text(
                  s.Feed,
                  style: titleTextStyle,
                );
                if (eventMemBox.length() <= 0) {
                  return text;
                }
                return _badge(text, themeData);
              },
              selector: (context, _provider) {
                return _provider.eventPostsMemBox;
              },
            ),
          ),
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Selector<FollowNewEventProvider, EventMemBox>(
              builder: (context, eventMemBox, child) {
                Text text = Text(
                  s.Following_replies,
                  style: titleTextStyle,
                );
                if (eventMemBox.length() <= 0) {
                  return text;
                }
                return _badge(text, themeData);
              },
              selector: (context, _provider) {
                return _provider.eventPostsAndRepliesMemBox;
              },
            ),
          ),
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Text(
              s.Global,
              style: titleTextStyle,
            ),
          ),
        ],
        controller: followTabController,
      );
    } else if (AppFeatures.enableNotifications &&
        _indexProvider.currentTap == IndexTaps.NOTIFICATIONS) {
      appBarCenter = Center(
        child: Text(
          s.Notifications,
          style: titleTextStyle,
        ),
      );
    } else if (AppFeatures.enableSearch &&
        _indexProvider.currentTap == IndexTaps.SEARCH) {
      appBarCenter = Center(
        child: Text(
          s.Search,
          style: titleTextStyle,
        ),
      );
    } else if (AppFeatures.enableDm &&
        _indexProvider.currentTap == IndexTaps.DM) {
      appBarCenter = TabBar(
        labelPadding: const EdgeInsets.only(
          left: Base.BASE_PADDING_HALF,
          right: Base.BASE_PADDING_HALF,
        ),
        controller: dmTabController,
        indicatorColor: const Color(0xFF6A1B9A),
        indicatorWeight: 2,
        tabs: [
          Container(
            height: IndexAppBar.height,
            alignment: Alignment.center,
            child: Selector<DMProvider, int>(
              builder: (context, count, child) {
                Text text = Text(s.Following, style: titleTextStyle);
                if (count <= 0) {
                  return text;
                }
                return _badge(text, themeData);
              },
              selector: (context, _provider) {
                return _provider.howManyNewDMSessionsWithNewMessages(
                    _provider.followingList);
              },
            ),
          ),
          Container(
              height: IndexAppBar.height,
              alignment: Alignment.center,
              child: Selector<DMProvider, int>(
                builder: (context, count, child) {
                  Text text = Text(
                    s.Others,
                    style: titleTextStyle,
                  );
                  if (count <= 0) {
                    return text;
                  }
                  return Badge(
                      offset: const Offset(16, -4),
                      // label: Text(count.toString(), style: badgeTextStyle),
                      backgroundColor: themeData.primaryColor,
                      child: text);
                },
                selector: (context, _provider) {
                  return _provider
                      .howManyNewDMSessionsWithNewMessages(_provider.knownList);
                },
              )),
          Container(
              height: IndexAppBar.height,
              alignment: Alignment.center,
              child: Selector<DMProvider, int>(
                builder: (context, count, child) {
                  Text text = Text(s.Requests, style: titleTextStyle);
                  if (count <= 0) {
                    return text;
                  }
                  return Badge(
                      offset: const Offset(0, -4),
                      // label: Text(count.toString(), style: badgeTextStyle),
                      backgroundColor: themeData.primaryColor,
                      child: text);
                },
                selector: (context, _provider) {
                  return _provider.howManyNewDMSessionsWithNewMessages(
                      _provider.unknownList);
                },
              )),
        ],
      );
    }

    var addBtn = FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: themeData.primaryColor,
      child: const Icon(Icons.add),
      onPressed: () {
        EditorRouter.open(context);
      },
    );

    // Only show FAB if social features are enabled
    var conditionalAddBtn = AppFeatures.enableSocial ? addBtn : null;

    var mainCenterWidget = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
          child: IndexedStack(
        index: _indexProvider.currentTap,
        children: [
          if (AppFeatures.isWalletOnly) const WalletRouter(showAppBar: false),
          if (AppFeatures.enableSocial)
            FollowIndexRouter(
              tabController: followTabController,
            ),
          if (AppFeatures.enableSearch) SearchRouter(),
          if (AppFeatures.enableDm)
            DMRouter(
              tabController: dmTabController,
              scrollCallback: scrollDirectionCallback,
            ),
          if (AppFeatures.enableNotifications) NotificationsRouter(),
          // NoticeRouter(),
        ],
      )),
    );

    var mainIndex = Column(
      children: [
        // AnimatedContainer(
        //     duration: const Duration(milliseconds: 300),
        //     curve: Curves.ease,
        //     height: _scrollingDown ? 0.0 : 80,
        //     child:
        if (!AppFeatures.isWalletOnly) ...[
          IndexAppBar(
            center: appBarCenter,
            // )
          ),
        ],
        mainCenterWidget,
      ],
    );

    if (PlatformUtil.isTableMode()) {
      // var maxWidth = mediaDataCache.size.width;
      // double column0Width = (maxWidth * 1) / 5;
      // if (column0Width > DRAWER_WIDTH) {
      //   column0Width = DRAWER_WIDTH;
      // }
      // if (column0Width < 280) {
      //   column0Width = 280;
      // }
      //
      // print("$column0Width + ${maxWidth - column0Width } = $maxWidth");
      return Scaffold(
        extendBody: true,
        floatingActionButton: conditionalAddBtn,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Row(children: [
          SizedBox(
            width: 350,
            child: IndexDrawerContentComponent(reload: widget.reload),
          ),
          // Container(
          //   width: column1Width,
          //   margin: const EdgeInsets.only(
          //     // left: 1,
          //     right: 1,
          //   ),
          //   child: mainIndex,
          // ),
          Expanded(
            child: Selector<PcRouterFakeProvider, List<RouterFakeInfo>>(
              builder: (context, infos, child) {
                if (infos.isEmpty) {
                  return mainIndex;
                }

                List<Widget> pages = [];
                for (var info in infos) {
                  if (info.buildContent != null) {
                    pages.add(PcRouterFake(
                      info: info,
                      child: info.buildContent!(context),
                    ));
                  } else if (StringUtil.isNotBlank(info.routerPath)) {
                    // This part is problematic as 'routes' is gone.
                    // For now, we'll log and skip creating a page for this.
                    // A proper fix would involve PcRouterFakeProvider.go
                    // being called with a WidgetBuilder or a direct Widget.
                    print(
                        "PcRouterFake: Attempted to use routerPath ('${info.routerPath}') without buildContent. This route cannot be displayed with the current GoRouter setup.");
                    // Optionally, add a placeholder page:
                    // pages.add(PcRouterFake(
                    //   info: info,
                    //   child: Center(child: Text("Error: Route for ${info.routerPath} not found via buildContent.")),
                    // ));
                  }
                }

                if (pages.isEmpty) {
                  // If no pages could be built (e.g., all infos relied on routerPath),
                  // fall back to mainIndex.
                  return mainIndex;
                }

                return IndexedStack(
                  index: pages.length - 1,
                  children: pages,
                );
              },
              selector: (context, _provider) {
                return _provider.routerFakeInfos;
              },
              shouldRebuild: (previous, next) {
                if (previous != next) {
                  return true;
                }
                return false;
              },
            ),
          )
        ]),
      );
    } else {
      // This is the non-tablet/PC mode
      return Scaffold(
          body: mainIndex,
          extendBody: true,
          floatingActionButton: loggedUserSigner != null &&
                  loggedUserSigner!.canSign() &&
                  AppFeatures.enableSocial
              ? AnimatedOpacity(
                  opacity: _scrollingDown ? 0 : 1,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 400),
                  child: addBtn,
                )
              : Container(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          drawer: Drawer(
            child: IndexDrawerContentComponent(reload: widget.reload),
          ),
          bottomNavigationBar: !AppFeatures.isWalletOnly
              ? AnimatedOpacity(
                  opacity: _scrollingDown ? 0 : 1,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease,
                      height: _scrollingDown ? 0.0 : 50,
                      child: IndexBottomBar()))
              : null);
    }
  } // End of doBuild method

  void doAuth() {
    AuthUtil.authenticate(
            context, I18n.of(context).Please_authenticate_to_use_app)
        .then((didAuthenticate) {
      if (didAuthenticate) {
        setState(() {
          unlock = true;
        });
      } else {
        doAuth();
      }
    });
  }
} // End of _IndexRouter class
