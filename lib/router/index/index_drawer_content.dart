import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/provider/index_provider.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/ui/user/metadata_top_component.dart';
import 'package:yana/utils/base.dart';
import 'package:go_router/go_router.dart';
import 'package:yana/utils/number_format_util.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/theme_style.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/metadata_provider.dart';
import '../../provider/relay_provider.dart';
import '../../utils/index_taps.dart';
import 'account_manager_component.dart';
import '../../config/app_features.dart';

class IndexDrawerContentComponent extends StatefulWidget {
  final Function reload;

  const IndexDrawerContentComponent({required this.reload, super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexDrawerContentComponnent();
  }
}

class _IndexDrawerContentComponnent extends State<IndexDrawerContentComponent> {
  double profileEditBtnWidth = 40;

  @override
  Widget build(BuildContext context) {
    var _indexProvider = Provider.of<IndexProvider>(context);
    var _relayProvider = Provider.of<RelayProvider>(context);

    var s = I18n.of(context);
    var pubkey = loggedUserSigner!.getPublicKey();
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    List<Widget> list = [];

    list.add(Stack(children: [
      FutureBuilder<Metadata?>(
          future: metadataProvider.getMetadata(pubkey),
          builder: (context, metadata) {
            return MetadataTopComponent(
              pubkey: pubkey,
              metadata: metadata.data,
              condensedIcons: true,
              jumpable: true,
            );
          })
    ]));

    list.add(Container(
        margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING * 2,
          bottom: Base.BASE_PADDING / 2,
          top: Base.BASE_PADDING / 2,
        ),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
          width: 1,
          color: hintColor,
        )))));

    if (PlatformUtil.isTableMode()) {
      if (AppFeatures.enableSocial) {
        list.add(IndexDrawerItem(
          iconData: Icons.home,
          name: s.Home,
          color:
              _indexProvider.currentTap == IndexTaps.FOLLOW ? mainColor : null,
          onTap: () {
            indexProvider.setCurrentTap(IndexTaps.FOLLOW);
          },
          onDoubleTap: () {
            indexProvider.followScrollToTop();
          },
        ));
      }
      if (AppFeatures.enableSearch) {
        list.add(IndexDrawerItem(
          iconData: Icons.search,
          name: s.Search,
          color:
              _indexProvider.currentTap == IndexTaps.SEARCH ? mainColor : null,
          onTap: () {
            indexProvider.setCurrentTap(IndexTaps.SEARCH);
          },
        ));
      }
      list.add(IndexDrawerItem(
        iconData: Icons.mail,
        name: s.Messages,
        color: _indexProvider.currentTap == IndexTaps.DM ? mainColor : null,
        onTap: () {
          indexProvider.setCurrentTap(IndexTaps.DM);
        },
      ));
      if (AppFeatures.enableNotifications) {
        list.add(IndexDrawerItem(
          iconData: Icons.notifications,
          name: s.Notifications,
          color: _indexProvider.currentTap == IndexTaps.NOTIFICATIONS
              ? mainColor
              : null,
          onTap: () {
            indexProvider.setCurrentTap(IndexTaps.NOTIFICATIONS);
          },
          onDoubleTap: () {
            // TODO
            // indexProvider.globalScrollToTop();
          },
        ));
      }
    }

    if (AppFeatures.enableSocial) {
      list.add(IndexDrawerItem(
        iconData: Icons.person,
        name: s.Profile,
        onTap: () {
          context.go(RouterPath.USER, extra: pubkey);
        },
      ));
    }

    if (loggedUserSigner!.canSign()) {
      if (AppFeatures.enableWallet) {
        list.add(IndexDrawerItem(
            iconData: Icons.account_balance_wallet,
            name: s.Wallet,
            onTap: () {
              context.go(RouterPath.WALLET);
            },
            rightWidget: Selector<NwcProvider, bool>(
                builder: (context, connected, child) {
              if (connected) {
                return Selector<NwcProvider, int?>(
                    builder: (context, balance, child) {
                  if (balance != null) {
                    return Row(children: [
                      const Icon(
                        Icons.currency_bitcoin,
                        color: Colors.orange,
                        size: 16,
                      ),
                      NumberFormatUtil.formatBitcoinAmount(
                        balance / 100000000,
                        TextStyle(color: themeData.focusColor),
                        TextStyle(color: themeData.dividerColor),
                      ),
                      const Text(
                        " sats",
                        style: TextStyle(
                            fontWeight: FontWeight.w100, fontSize: 12),
                      )
                    ]);
                  } else {
                    return Text(
                      "connected",
                      style: TextStyle(color: themeData.disabledColor),
                    );
                  }
                }, selector: (context, _provider) {
                  return _provider.isConnected ? _provider.getBalance : null;
                });
              } else {
                return Text(
                  "not connected",
                  style: TextStyle(color: themeData.disabledColor),
                );
              }
            }, selector: (context, _provider) {
              return _provider.isConnected;
            })));
      }
    }
    list.add(
      IndexDrawerItem(
          iconData: Icons.lan_outlined,
          name: s.Relays,
          onTap: () {
            context.go(RouterPath.RELAYS);
          },
          rightWidget: Selector<RelayProvider, String>(
              builder: (context, relayNum, child) {
            return Text(
              relayNum,
              style: TextStyle(color: themeData.disabledColor),
            );
          }, selector: (context, _provider) {
            return _provider.relayNumStr();
          })),
    );

    if (loggedUserSigner!.canSign() && loggedUserSigner is! AmberEventSigner) {
      list.add(IndexDrawerItem(
        iconData: Icons.key,
        name: s.Key_Backup,
        onTap: () {
          context.go(RouterPath.KEY_BACKUP);
        },
      ));
    }

    list.add(IndexDrawerItem(
      iconData: Icons.settings,
      name: s.Settings,
      onTap: () {
        context.go(RouterPath.SETTING);
      },
    ));

    list.add(Expanded(child: Container()));

    list.add(IndexDrawerItem(
      iconData: Icons.supervisor_account,
      name: s.Accounts,
      onTap: () {
        _showBasicModalBottomSheet(context);
      },
    ));
    list.add(Container(
      margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING_HALF,
        top: Base.BASE_PADDING / 2,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
        width: 1,
        color: hintColor,
      ))),
      alignment: Alignment.centerLeft,
      child: Row(children: [
        IconButton(
            onPressed: () {
              if (settingProvider.themeStyle == ThemeStyle.AUTO) {
                Brightness platformBrightness =
                    MediaQuery.of(context).platformBrightness;
                if (platformBrightness == Brightness.light) {
                  settingProvider.themeStyle = ThemeStyle.DARK;
                } else {
                  settingProvider.themeStyle = ThemeStyle.LIGHT;
                }
              } else {
                if (settingProvider.themeStyle == ThemeStyle.DARK) {
                  settingProvider.themeStyle = ThemeStyle.LIGHT;
                } else {
                  settingProvider.themeStyle = ThemeStyle.DARK;
                }
              }
              widget.reload();
            },
            icon: Icon(settingProvider.themeStyle == ThemeStyle.LIGHT ||
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined)),
        Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: const EdgeInsets.only(right: Base.BASE_PADDING),
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            onTap: () {
                              var url = Uri.parse(
                                  "https://github.com/frnandu/yana/releases");
                              launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                            child: Text("v${packageInfo.version}",
                                style: TextStyle(
                                    color: themeData.disabledColor)))))))
      ]),
    ));

    return Column(
      children: list,
    );
  }

  void _showBasicModalBottomSheet(context) async {
    showModalBottomSheet(
      isScrollControlled: false, // true 为 全屏
      context: context,
      builder: (BuildContext context) {
        return AccountsComponent();
      },
    );
  }
}

class IndexDrawerItem extends StatelessWidget {
  final IconData iconData;
  final String name;
  final Function onTap;
  final Function? onDoubleTap;
  final Color? color;
  final Widget? rightWidget;

  const IndexDrawerItem({
    super.key,
    required this.iconData,
    required this.name,
    required this.onTap,
    this.color,
    this.onDoubleTap,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    List<Widget> list = [];

    list.add(MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(
            left: Base.BASE_PADDING * 1.5,
            right: Base.BASE_PADDING,
          ),
          child: Icon(
            iconData,
            color: color,
          ),
        )));

    list.add(MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(name,
            style: TextStyle(
                color: color,
                fontSize: Base.BASE_FONT_SIZE + 3,
                fontFamily: "Geist"))));

    if (rightWidget != null) {
      list.add(MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
              margin: const EdgeInsets.only(
                left: Base.BASE_PADDING,
              ),
              child: rightWidget!)));
    }

    return GestureDetector(
      onTap: () {
        onTap();
      },
      onDoubleTap: () {
        if (onDoubleTap != null) {
          onDoubleTap!();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 40,
        child: Row(
          children: list,
        ),
      ),
    );
  }
}
