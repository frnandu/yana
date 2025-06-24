import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk_amber/data_layer/repositories/signers/amber_event_signer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/ui/qrcode_dialog.dart';
import 'package:yana/utils/number_format_util.dart';
import 'package:yana/utils/router_path.dart';
import 'package:yana/utils/string_util.dart';

import '../../config/app_features.dart';
import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../provider/relay_provider.dart';
import 'account_manager_component.dart';

class IndexDrawerContentComponent extends StatefulWidget {
  final Function reload;

  const IndexDrawerContentComponent({required this.reload, super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexDrawerContentComponnent();
  }
}

class _IndexDrawerContentComponnent extends State<IndexDrawerContentComponent> {
  @override
  Widget build(BuildContext context) {
    var s = I18n.of(context);
    var pubkey = loggedUserSigner!.getPublicKey();
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    var version = packageInfo.version;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          children: [
            // Header/Profile Section (banner, avatar, icons)
            Container(
              color: themeData.scaffoldBackgroundColor,//appBarTheme.backgroundColor!,
              child: SizedBox(
                height: 220,
                child: FutureBuilder<Metadata?>(
                  future: metadataProvider.getMetadata(pubkey),
                  builder: (context, metadata) {
                    final meta = metadata.data;
                    final bannerUrl = meta != null &&
                            meta.banner != null &&
                            meta.banner!.isNotEmpty
                        ? meta.banner!
                        : "assets/imgs/banner.jpeg";
                    final avatarUrl = meta != null &&
                            meta.picture != null &&
                            meta.picture!.isNotEmpty
                        ? meta.picture!
                        : StringUtil.robohash(pubkey);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Banner
                        GestureDetector(
                          onTap: () =>
                              context.push(RouterPath.USER, extra: pubkey),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(24),
                            ),
                            child: bannerUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: bannerUrl,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(bannerUrl,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                          ),
                        ),
                        // Avatar
                        Positioned(
                          left: 24,
                          top: 110,
                          child: GestureDetector(
                            onTap: () =>
                                context.push(RouterPath.USER, extra: pubkey),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        themeData.scaffoldBackgroundColor,//appBarTheme.backgroundColor!,
                                    width: 8),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundImage: avatarUrl.startsWith('http')
                                    ? CachedNetworkImageProvider(avatarUrl)
                                    : AssetImage(avatarUrl) as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                        // QR and Edit icons
                        Positioned(
                          left: 180,
                          top: 180,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.qr_code, size: 28),
                                color: themeData.hintColor,
                                onPressed: () {
                                  QrcodeDialog.show(context, pubkey);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 28),
                                color: themeData.hintColor,
                                onPressed: () =>
                                    context.push(RouterPath.PROFILE_EDITOR),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.scaffoldBackgroundColor,//appBarTheme.backgroundColor!,
                ),
                child: Column(
                  children: [
                    if (loggedUserSigner!.canSign() &&
                        AppFeatures.enableWallet) ...[
                      _DrawerNavItem(
                        icon: Icons.account_balance_wallet,
                        label: s.Wallet,
                        trailing: Selector<NwcProvider, bool>(
                          builder: (context, connected, child) {
                            if (connected) {
                              return Selector<NwcProvider, int?>(
                                builder: (context, balance, child) {
                                  if (balance != null) {
                                    return SizedBox(
                                      width: 130,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.currency_bitcoin,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          NumberFormatUtil.formatBitcoinAmount(
                                            balance / 100000000,
                                            TextStyle(
                                                color: themeData.focusColor),
                                            TextStyle(
                                                color: themeData.primaryColor),
                                          ),
                                          Text(
                                            " sats",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                color: themeData.primaryColor,
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      "connected",
                                      style: TextStyle(
                                          color: themeData.disabledColor),
                                    );
                                  }
                                },
                                selector: (context, _provider) {
                                  return _provider.isConnected
                                      ? _provider.getBalance
                                      : null;
                                },
                              );
                            } else {
                              return Text(
                                "not connected",
                                style:
                                    TextStyle(color: themeData.disabledColor),
                              );
                            }
                          },
                          selector: (context, _provider) {
                            return _provider.isConnected;
                          },
                        ),
                        onTap: () => context.push(RouterPath.WALLET),
                      ),
                    ],
                    if (AppFeatures.enableWallet ||
                        AppFeatures.enableSocial ||
                        AppFeatures.enableDm) ...[
                      _DrawerNavItem(
                        icon: Icons.lan_outlined,
                        label: s.Relays,
                        trailing: Selector<RelayProvider, String>(
                          selector: (context, provider) =>
                              provider.relayNumStr(),
                          builder: (context, relayNum, child) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeData.cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(relayNum,
                                style: TextStyle(
                                    //color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        onTap: () => context.push(RouterPath.RELAYS),
                      ),
                    ],
                    if (loggedUserSigner!.canSign() &&
                        loggedUserSigner is! AmberEventSigner) ...[
                      _DrawerNavItem(
                        icon: Icons.key,
                        label: s.Key_Backup,
                        onTap: () => context.push(RouterPath.KEY_BACKUP),
                      ),
                    ],
                    _DrawerNavItem(
                      icon: Icons.settings,
                      label: s.Settings,
                      onTap: () => context.push(RouterPath.SETTING),
                    ),
                    // // Modules (example, always shown)
                    // _DrawerNavItem(
                    //   icon: Icons.extension,
                    //   label: 'Modules',
                    //   onTap: () {}, // TODO: Implement modules navigation
                    // ),
                    const Spacer(),
                    Divider(color: themeData.hintColor.withOpacity(0.2)),
                    _DrawerNavItem(
                      icon: Icons.switch_account,
                      label: 'Switch Profile',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => AccountsComponent(),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                        );
                      },
                    ),
                    _DrawerNavItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      labelColor: Color(0xFFd9495a),
                      onTap: () async {
                        var index = settingProvider.privateKeyIndex;
                        if (index != null) {
                          AccountsState.onLogoutTap(index, context: context);
                        }
                      },
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 16, top: 8, right: 16),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                  onTap: () {
                                    var url = Uri.parse(
                                        "https://github.com/frnandu/yana/releases");
                                    launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  },
                                  child: Text(
                                    'v$version',
                                    style: TextStyle(
                                        color: themeData.hintColor,
                                        fontSize: 12),
                                  )))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: labelColor),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontFamily: 'Geist',
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white10,
    );
  }
}
