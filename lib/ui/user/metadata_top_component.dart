import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ndk/entities.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yana/main.dart';
import 'package:yana/nostr/nip19/nip19_tlv.dart';
import 'package:yana/provider/contact_list_provider.dart';
import 'package:yana/provider/filter_provider.dart';
import 'package:yana/ui/nip05_valid_component.dart';
import 'package:yana/ui/qrcode_dialog.dart';
import 'package:yana/ui/zap_gen_dialog.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_path.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_features.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip57/zap_action.dart';
import '../../provider/data_util.dart';
import '../../utils/base.dart';
import '../../utils/string_util.dart';
import '../image_preview_dialog.dart';

class MetadataTopComponent extends StatefulWidget {
  static double getPcBannerHeight(double maxHeight) {
    var height = maxHeight * 0.2;
    if (height > 200) {
      return 200;
    }

    return height;
  }

  String pubkey;

  Metadata? metadata;

  bool condensedIcons;
  bool jumpable;

  bool userPicturePreview;

  bool followsYou;

  MetadataTopComponent({
    super.key,
    required this.pubkey,
    this.condensedIcons = false,
    this.metadata,
    this.jumpable = false,
    this.userPicturePreview = false,
    this.followsYou = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _MetadataTopComponent();
  }
}

class _MetadataTopComponent extends State<MetadataTopComponent> {
  static const double IMAGE_BORDER = 4;

  static const double IMAGE_WIDTH = 80;

  static const double HALF_IMAGE_WIDTH = 40;

  late String nip19PubKey;

  List<String>? contacts;

  @override
  void initState() {
    super.initState();

    Future(() async {
      List<String>? a = await contactListProvider?.contacts();
      setState(() {
        contacts = a;
      });
    });
    nip19PubKey = Nip19.encodePubKey(widget.pubkey);
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;
    var scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;
    var maxWidth = mediaDataCache.size.width;
    var largeFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var fontSize = themeData.textTheme.bodyMedium!.fontSize;
    var _filterProvider = Provider.of<FilterProvider>(context);
    var bannerHeight = maxWidth / 3;
    if (PlatformUtil.isTableMode()) {
      bannerHeight =
          MetadataTopComponent.getPcBannerHeight(mediaDataCache.size.height);
    }

    String nip19Name = Nip19.encodeSimplePubKey(widget.pubkey);
    String displayName = "";
    String? name;
    if (widget.metadata != null) {
      if (StringUtil.isNotBlank(widget.metadata!.displayName)) {
        displayName = widget.metadata!.displayName!;
        if (StringUtil.isNotBlank(widget.metadata!.name)) {
          name = widget.metadata!.name;
        }
      } else if (StringUtil.isNotBlank(widget.metadata!.name)) {
        displayName = widget.metadata!.name!;
      }
    }

    Widget? imageWidget;
    String? url = widget.metadata != null &&
            StringUtil.isNotBlank(widget.metadata?.picture)
        ? widget.metadata?.picture
        : StringUtil.robohash(widget.pubkey);

    if (url != null) {
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        width: IMAGE_WIDTH,
        height: IMAGE_WIDTH,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        cacheManager: localCacheManager,
      );
    }
    Widget? bannerImage;
    if (widget.metadata != null &&
        StringUtil.isNotBlank(widget.metadata!.banner)) {
      bannerImage = CachedNetworkImage(
        imageUrl: widget.metadata!.banner!,
        width: maxWidth,
        height: bannerHeight,
        fit: BoxFit.cover,
        cacheManager: localCacheManager,
      );
    } else {
      bannerImage = Image.asset(
        fit: BoxFit.cover,
        "assets/imgs/banner.jpeg",
      );
    }

    List<Widget> topBtnList = [
      Expanded(
        child: Container(),
      )
    ];

    if (widget.pubkey == loggedUserSigner!.getPublicKey() &&
        loggedUserSigner!.canSign()) {
      topBtnList.add(wrapBtn(
        MetadataIconBtn(
          iconData: Symbols.edit_square,
          onTap: jumpToProfileEdit,
        ),
      )
          // if (!PlatformUtil.isTableMode() && widget.pubkey == loggedUserSigner!.getPublicKey()) {
          //   // is phont and local
          //   topBtnList.add(wrapBtn(MetadataIconBtn(
          //     iconData: Icons.qr_code_scanner,
          //     onTap: handleScanner,
          //   )));
          // }
          );
    }
    if (widget.followsYou &&
        widget.pubkey != loggedUserSigner!.getPublicKey()) {
      topBtnList.add(
          // MetadataIconDataComp(
          //   leftWidget: Container(),
          //   text: "follows you",
          //   textBG: true,
          //   onTap: copyPubKey,
          // )
          Container(
              decoration: BoxDecoration(
                color: themeData.dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.only(top: 4, bottom: 4, left: 6, right: 5),
              margin: const EdgeInsets.only(right: 3, top: 8),
              child: Text(
                "follows you",
                style: TextStyle(
                  color: themeData.hintColor,
                  fontSize: themeData.textTheme.labelSmall!.fontSize! - 2,
                ),
              )));
    }

    topBtnList.add(wrapBtn(MetadataIconBtn(
      iconData: Symbols.qr_code,
      onTap: () {
        QrcodeDialog.show(context, widget.pubkey);
      },
    )));

    if (!widget.condensedIcons) {
      if (widget.metadata != null &&
          (StringUtil.isNotBlank(widget.metadata!.lud06) ||
              StringUtil.isNotBlank(widget.metadata!.lud16))) {
        topBtnList.add(wrapBtn(PopupMenuButton<int>(
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 21,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 21")
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 69,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 69")
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 210,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 210")
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 420,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 420")
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 2100")
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 4200,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orange),
                    Text(" Zap 4200")
                  ],
                ),
              ),
            ];
          },
          onSelected: onZapSelect,
          child: MetadataIconBtn(
            onLongPress: () {
              ZapGenDialog.show(context, widget.pubkey, onZapped: (success) {});
            },
            iconData: Symbols.bolt,
            iconColor: Colors.orange,
          ),
        )));
      }
      if (widget.pubkey != loggedUserSigner!.getPublicKey()) {
        if (loggedUserSigner!.canSign()) {
          topBtnList.add(wrapBtn(MetadataIconBtn(
            iconData: Symbols.mail,
            onTap: openDMSession,
          )));
          topBtnList.add(Selector<ContactListProvider, bool>(
            builder: (context, followed, child) {
              if (followed == null || !followed) {
                return wrapBtn(MetadataTextBtn(
                  text: "Follow",
                  borderColor: mainColor,
                  onTap: () async {
                    bool finished = false;
                    Future.delayed(const Duration(seconds: 1), () {
                      if (!finished) {
                        EasyLoading.show(
                            status:
                                "Refreshing contacts from relays before following...",
                            maskType: EasyLoadingMaskType.black);
                      }
                    });
                    await contactListProvider?.addContact(widget.pubkey);
                    finished = true;
                    EasyLoading.dismiss();
                  },
                ));
              } else {
                return wrapBtn(MetadataTextBtn(
                  text: "Unfollow",
                  borderColor: mainColor,
                  onTap: () async {
                    bool finished = false;
                    Future.delayed(const Duration(seconds: 1), () {
                      if (!finished) {
                        EasyLoading.show(
                            status:
                                "Refreshing contacts from relays before unfollowing...",
                            maskType: EasyLoadingMaskType.black);
                      }
                    });
                    await contactListProvider?.removeContact(widget.pubkey);
                    finished = true;
                    EasyLoading.dismiss();
                  },
                ));
              }
            },
            selector: (context, _provider) {
              return contacts != null
                  ? contacts!.contains(widget.pubkey)
                  : false;
            },
          ));
        }
        topBtnList.add(Container(
          margin:
              const EdgeInsets.only(top: Base.BASE_PADDING, right: 6, left: 6),
          child: PopupMenuButton<String>(
            tooltip: "more",
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> list = [
                PopupMenuItem(
                  value: "login_as",
                  child: Text("Login as ${displayName}"),
                ),
                const PopupMenuItem(value: "share", child: Text("Share..."))
              ];
              if (filterProvider.isMutedPubKey(widget.pubkey)) {
                list.add(const PopupMenuItem(
                    value: "unmute", child: Text("Unmute profile")));
              } else {
                list.add(const PopupMenuItem(
                    value: "mute-public",
                    child: Text("Mute profile (public)")));
                list.add(const PopupMenuItem(
                    value: "mute-private",
                    child: Text("Mute profile (private)")));
              }
              return list;
            },
            onSelected: (value) async {
              if (value == "login_as") {
                EasyLoading.showToast("Logging in as ${displayName}...",
                    dismissOnTap: true,
                    duration: const Duration(seconds: 5),
                    maskType: EasyLoadingMaskType.black);
                sharedPreferences.remove(DataKey.NOTIFICATIONS_TIMESTAMP);
                sharedPreferences.remove(DataKey.FEED_POSTS_TIMESTAMP);
                sharedPreferences.remove(DataKey.FEED_REPLIES_TIMESTAMP);
                if (AppFeatures.enableNotifications) {
                  notificationsProvider?.clear();
                  newNotificationsProvider?.clear();
                }
                followEventProvider?.clear();
                followNewEventProvider?.clear();
                settingProvider.addAndChangeKey(widget.pubkey, false, false,
                    updateUI: true);
                String publicKey = widget.pubkey;
                ndk.accounts.loginPublicKey(pubkey: publicKey);
                // ndk = Ndk(
                //     NdkConfig(
                //       eventVerifier: eventVerifier,
                //       cache: cacheManager,
                //       eventSigner: Bip340EventSigner(privateKey: null, publicKey: publicKey),
                //       eventOutFilters:  [filterProvider]
                //     ));
                await initRelays(newKey: false);
                followEventProvider?.loadCachedFeed();
                nwcProvider?.init();
                settingProvider.notifyListeners();
                EasyLoading.dismiss();
                context.pop();
              } else if (value == "share") {
                UserRelayList? userRelayList =
                    await cacheManager.loadUserRelayList(widget.pubkey);
                List<String> relays = ndk.config.bootstrapRelays;
                if (userRelayList != null && userRelayList.relays != null) {
                  relays = userRelayList!.relays!.keys!.toList();
                }
                var nevent = Nprofile(pubkey: widget.pubkey, relays: relays);

                String share =
                    'https://njump.me/${NIP19Tlv.encodeNprofile(nevent).replaceAll("nostr:", "")}';
                Share.share(share);
              } else if (value.startsWith("mute-")) {
                Nip51List muteList = await ndk.lists
                    .broadcastAddNip51ListElement(
                        Nip51List.kMute,
                        Nip51List.kPubkey,
                        widget.pubkey,
                        myOutboxRelaySet!.urls,
                        private: value == "mute-private");
                filterProvider.muteList = muteList;
                filterProvider.notifyListeners();
                setState(() {});
              } else if (value == "unmute") {
                Nip51List? muteList = await ndk.lists
                    .broadcastRemoveNip51ListElement(
                        Nip51List.kMute,
                        Nip51List.kPubkey,
                        widget.pubkey,
                        myOutboxRelaySet!.urls);
                if (muteList != null) {
                  filterProvider.muteList = muteList;
                  filterProvider.notifyListeners();
                  setState(() {});
                }
              }
            },
            child: const Icon(
              Symbols.more_vert_sharp,
              size: 30,
              color: Colors.white,
            ),
          ),
        ));
      }
    }

    List<Widget> nameList = [];

    if (StringUtil.isBlank(displayName)) {
      displayName = nip19Name;
    }
    nameList.add(Text(
      displayName,
      style: TextStyle(
        fontSize: largeFontSize,
        fontWeight: FontWeight.bold,
      ),
    ));
    if (StringUtil.isNotBlank(name)) {
      nameList.add(Container(
        margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
        child: Text(
          name != null ? "@$name" : "",
          style: TextStyle(
            fontSize: fontSize,
            color: hintColor,
          ),
        ),
      ));
    }

    Widget userNameComponent = Container(
      height: 40,
      width: double.maxFinite,
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        // top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      // color: Colors.green,
      child: Row(
        children: nameList,
      ),
    );
    if (widget.jumpable) {
      userNameComponent = GestureDetector(
        onTap: jumpToUserRouter,
        child: userNameComponent,
      );
    }

    List<Widget> topList = [];
    topList.add(Container(
        width: maxWidth,
        height: bannerHeight,
        color: themeData.cardColor, //Colors.grey.withOpacity(0.5),
        child: widget.jumpable
            ? GestureDetector(onTap: jumpToUserRouter, child: bannerImage)
            : bannerImage));
    topList.add(Container(
      height: 50,
      // color: Colors.red,
      child: Row(
        children: topBtnList,
      ),
    ));
    if (widget.metadata != null && !widget.condensedIcons) {
      topList.add(userNameComponent);
    }

    if (!widget.condensedIcons) {
      topList.add(MetadataIconDataComp(
        iconData: Icons.copy,
        text: nip19PubKey,
        textBG: true,
        onTap: copyPubKey,
      ));
    }

    if (widget.metadata != null && !widget.condensedIcons) {
      if (StringUtil.isNotBlank(widget.metadata!.nip05)) {
        topList.add(MetadataIconDataComp(
          text: widget.metadata!.cleanNip05!,
          leftWidget: Nip05ValidComponent(metadata: widget.metadata!),
        ));
      }
      if (widget.metadata != null) {
        if (StringUtil.isNotBlank(widget.metadata!.website)) {
          topList.add(MetadataIconDataComp(
            iconData: Icons.link,
            textColor: themeData.primaryColor,
            text: widget.metadata!.website!,
            onTap: () {
              String url = widget.metadata!.website!;
              if (!url.startsWith("https://") && !url.startsWith("http://")) {
                url = "https://" + url;
              }
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              // WebViewRouter.open(context, widget.metadata!.website!);
            },
          ));
        }
        if (StringUtil.isNotBlank(widget.metadata!.lud16)) {
          topList.add(MetadataIconDataComp(
            iconData: Icons.bolt,
            iconColor: Colors.orange,
            text: widget.metadata!.lud16!,
          ));
        }
      }
    }

    Widget userImageWidget = Container(
      alignment: Alignment.center,
      height: IMAGE_WIDTH,
      width: IMAGE_WIDTH,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HALF_IMAGE_WIDTH),
        color: Colors.grey,
      ),
      child: imageWidget,
    );
    if (widget.userPicturePreview) {
      userImageWidget = GestureDetector(
        onTap: userPicturePreview,
        child: userImageWidget,
      );
    } else if (widget.jumpable) {
      userImageWidget = GestureDetector(
        onTap: jumpToUserRouter,
        child: userImageWidget,
      );
    }

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: topList,
        ),
        Positioned(
          left: Base.BASE_PADDING,
          top: bannerHeight - HALF_IMAGE_WIDTH,
          child: Container(
            height: IMAGE_WIDTH + IMAGE_BORDER * 2,
            width: IMAGE_WIDTH + IMAGE_BORDER * 2,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(HALF_IMAGE_WIDTH + IMAGE_BORDER),
              border: Border.all(
                width: IMAGE_BORDER,
                color: scaffoldBackgroundColor,
              ),
            ),
            child: userImageWidget,
          ),
        )
      ],
    );
  }

  Widget wrapBtn(Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 2),
      child: child,
    );
  }

  copyPubKey() {
    Clipboard.setData(ClipboardData(text: nip19PubKey));
  }

  void jumpToUserRouter() {
    context.go(RouterPath.USER, extra: widget.pubkey);
  }

  void openDMSession() {
    if (!AppFeatures.enableDm) {
      EasyLoading.showToast("DM feature is not enabled in this build.",
          dismissOnTap: true, duration: const Duration(seconds: 3));
      return;
    }
    var detail = dmProvider!.findOrNewADetail(widget.pubkey);
    context.go(RouterPath.DM_DETAIL, extra: detail);
  }

  void onZapSelect(int sats) {
    ZapAction.handleZap(context, sats, widget.pubkey, onZapped: (bool) {});
  }

  void jumpToProfileEdit() {
    context.go(RouterPath.PROFILE_EDITOR);
  }

  void userPicturePreview() {
    String? url = widget.metadata != null &&
            StringUtil.isNotBlank(widget.metadata?.picture)
        ? widget.metadata?.picture
        : StringUtil.robohash(widget.pubkey);

    if (url != null) {
      List<ImageProvider> imageProviders = [];
      imageProviders.add(CachedNetworkImageProvider(url));

      MultiImageProvider multiImageProvider =
          MultiImageProvider(imageProviders, initialIndex: 0);

      ImagePreviewDialog.show(context, multiImageProvider,
          doubleTapZoomable: true, swipeDismissible: true);
    }
  }
}

class MetadataIconBtn extends StatelessWidget {
  void Function()? onTap;

  void Function()? onLongPress;

  IconData iconData;
  Color? iconColor;

  MetadataIconBtn(
      {super.key,
      required this.iconData,
      this.iconColor,
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    var decoration = BoxDecoration(
        // borderRadius: BorderRadius.circular(20),
        // border: Border.all(width: 1),
        );
    var main = Container(
      // height: 34,
      // width: 34,
      child: Icon(iconData,
          size: 30, weight: 1, color: iconColor ?? iconTheme.color),
    );

    if (onTap != null || onLongPress != null) {
      // return Ink(
      //   decoration: decoration,
      //   child: InkWell(
      //     onTap: onTap,
      //     onLongPress: onLongPress,
      //     child: main,
      //   ),
      // );
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: decoration,
          child: main,
        ),
      );
    } else {
      return Container(
        decoration: decoration,
        child: main,
      );
    }
  }
}

class MetadataTextBtn extends StatelessWidget {
  void Function() onTap;

  String text;

  Color? borderColor;

  MetadataTextBtn({
    super.key,
    required this.text,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(width: 1, color: borderColor!)
            : Border.all(width: 1),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: Base.BASE_FONT_SIZE - 1,
            // fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    );
  }
}

class MetadataIconDataComp extends StatelessWidget {
  String text;

  IconData? iconData;

  Color? iconColor;

  Color? textColor;

  bool textBG;

  Function? onTap;

  Widget? leftWidget;

  MetadataIconDataComp({
    super.key,
    required this.text,
    this.iconData,
    this.leftWidget,
    this.iconColor,
    this.textColor,
    this.textBG = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Color? cardColor = themeData.cardColor;
    if (cardColor == Colors.white) {
      cardColor = Colors.grey[300];
    }

    iconData ??= Icons.circle;

    return Container(
      padding: const EdgeInsets.only(
        bottom: Base.BASE_PADDING_HALF,
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(
                right: Base.BASE_PADDING_HALF,
              ),
              child: leftWidget ??
                  Icon(
                    iconData,
                    color: iconColor,
                    size: 16,
                  ),
            ),
            Expanded(
              child: Container(
                padding: textBG
                    ? const EdgeInsets.only(
                        left: Base.BASE_PADDING_HALF,
                        right: Base.BASE_PADDING_HALF,
                        top: 4,
                        bottom: 4,
                      )
                    : null,
                decoration: BoxDecoration(
                  color: textBG ? cardColor : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  style: TextStyle(color: textColor ?? themeData.hintColor),
                  text,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
