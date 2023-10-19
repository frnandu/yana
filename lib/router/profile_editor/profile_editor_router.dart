import 'dart:convert';
import 'dart:developer';

import 'package:dart_ndk/nips/nip01/event.dart';
import 'package:flutter/material.dart';
import 'package:yana/models/metadata.dart';
import 'package:yana/nostr/upload/uploader.dart';
import 'package:yana/provider/relay_provider.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/relay_status.dart';
import '../../nostr/event.dart';
import '../../nostr/event_kind.dart' as kind;
import '../../nostr/filter.dart';
import '../../nostr/nostr.dart';
import '../../nostr/relay.dart';
import '../../ui/appbar4stack.dart';
import '../../ui/cust_state.dart';
import '../../utils/base.dart';

class ProfileEditorRouter extends StatefulWidget {
  const ProfileEditorRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileEditorRouter();
  }
}

class _ProfileEditorRouter extends CustState<ProfileEditorRouter> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController pictureController = TextEditingController();
  TextEditingController bannerController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController nip05Controller = TextEditingController();
  TextEditingController lud16Controller = TextEditingController();
  TextEditingController lud06Controller = TextEditingController();

  Metadata? metadata;

  String getText(String? str) {
    return str != null ? str : "";
  }

  @override
  Widget doBuild(BuildContext context) {
    var s = I18n.of(context);
    if (metadata == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is Metadata) {
        metadata = arg;
      }
      metadata ??= Metadata();

      displayNameController.text = getText(metadata!.displayName);
      nameController.text = getText(metadata!.name);
      aboutController.text = getText(metadata!.about);
      pictureController.text = getText(metadata!.picture);
      bannerController.text = getText(metadata!.banner);
      websiteController.text = getText(metadata!.website);
      nip05Controller.text = getText(metadata!.nip05);
      lud16Controller.text = getText(metadata!.lud16);
      lud06Controller.text = getText(metadata!.lud06);
    }

    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;
    var textColor = themeData.textTheme.bodyMedium!.color;

    var submitBtn = TextButton(
      child: Text(
        s.Submit,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      onPressed: profileSave,
      style: ButtonStyle(),
    );

    Color? appbarBackgroundColor = Colors.transparent;
    var appBar = Appbar4Stack(
      backgroundColor: appbarBackgroundColor,
      // title: appbarTitle,
      action: Container(
        margin: EdgeInsets.only(right: Base.BASE_PADDING),
        child: submitBtn,
      ),
    );

    var margin = EdgeInsets.only(bottom: Base.BASE_PADDING);
    var padding = EdgeInsets.only(left: 20, right: 20);

    List<Widget> list = [];

    if (PlatformUtil.isTableMode()) {
      list.add(Container(
        height: 30,
      ));
    }

    list.add(Container(
      margin: margin,
      padding: padding,
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: displayNameController,
            decoration: InputDecoration(labelText: s.Display_Name),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: Base.BASE_PADDING_HALF,
            right: Base.BASE_PADDING_HALF,
          ),
          child: Text(" @ "),
        ),
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: s.Name),
          ),
        ),
      ]),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        minLines: 2,
        maxLines: 10,
        controller: aboutController,
        decoration: InputDecoration(labelText: s.About),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: pictureController,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: pickPicture,
            child: Icon(Icons.image),
          ),
          labelText: s.Picture,
        ),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: bannerController,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: pickBanner,
            child: Icon(Icons.image),
          ),
          labelText: s.Banner,
        ),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: websiteController,
        decoration: InputDecoration(labelText: s.Website),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: nip05Controller,
        decoration: InputDecoration(labelText: s.Nip05),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: lud16Controller,
        decoration: InputDecoration(
            labelText: s.Lud16, hintText: "walletname@walletservice.com"),
      ),
    ));

    list.add(Container(
      margin: margin,
      padding: padding,
      child: TextField(
        controller: lud06Controller,
        decoration: InputDecoration(labelText: "Lnurl"),
      ),
    ));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: cardColor,
              padding: EdgeInsets.only(
                  top: mediaDataCache.padding.top + Base.BASE_PADDING),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: list,
                ),
              ),
            ),
          ),
          Positioned(
            top: mediaDataCache.padding.top,
            left: 0,
            right: 0,
            child: Container(
              child: appBar,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickPicture() async {
    var filepath = await pickImageAndUpload();
    if (StringUtil.isNotBlank(filepath)) {
      pictureController.text = filepath!;
    }
  }

  Future<void> pickBanner() async {
    var filepath = await pickImageAndUpload();
    if (StringUtil.isNotBlank(filepath)) {
      bannerController.text = filepath!;
    }
  }

  Future<String?> pickImageAndUpload() async {
    if (PlatformUtil.isWeb()) {
      // TODO ban image update at web temp
      return null;
    }

    var filepath = await Uploader.pick(context);
    if (StringUtil.isNotBlank(filepath)) {
      return await Uploader.upload(
        filepath!,
        imageService: settingProvider.imageService,
      );
    }
  }

  void profileSave() {
    Map<String, dynamic>? metadataMap;
    if (profileEvent != null) {
      try {
        metadataMap = jsonDecode(profileEvent!.content);
      } catch (e) {
        log("profileSave jsonDecode error");
        print(e);
      }
    } else {
      metadataMap = {};
    }

    metadataMap!["display_name"] = displayNameController.text;
    metadataMap["name"] = nameController.text;
    metadataMap["about"] = aboutController.text;
    metadataMap["picture"] = pictureController.text;
    metadataMap["banner"] = bannerController.text;
    metadataMap["website"] = websiteController.text;
    metadataMap["nip05"] = nip05Controller.text;
    metadataMap["lud16"] = lud16Controller.text;
    metadataMap["lud06"] = lud06Controller.text;

    // Set<String> uniqueRelays = Set<String>.from(RelayProvider.STATIC_RELAY_ADDRS);
    // uniqueRelays.addAll(relayProvider.relayAddrs);
    // var tempNostr = Nostr(privateKey: nostr!.privateKey, publicKey: nostr!.publicKey);

    // TODO use dart_ndk

    // uniqueRelays.forEach((relayAddr) {
    //   Relay r = Relay(
    //     relayAddr,
    //     RelayStatus(relayAddr),
    //     access: WriteAccess.readWrite,
    //   );
    //   try {
    //     tempNostr.addRelay(r, checkInfo: false);
    //   } catch (e) {
    //     log("relay $relayAddr add to temp nostr for broadcasting of nip065 relay list: ${e.toString()}");
    //   }
    // });

    // TODO use dart_ndk

    // var updateEvent = Nip01Event(pubKey:
    //     tempNostr!.publicKey, kind: kind.EventKind.METADATA, tags: [], content: jsonEncode(metadataMap));
    // tempNostr!.sendEvent(updateEvent);

    RouterUtil.back(context);
  }

  Event? profileEvent;

  @override
  Future<void> onReady(BuildContext context) async {
    var filter = Filter(
        kinds: [kind.EventKind.METADATA],
        authors: [nostr!.publicKey],
        limit: 1);
    nostr!.query([filter.toJson()], (event) {
      if (profileEvent == null) {
        profileEvent = event;
      } else if (event.createdAt > profileEvent!.createdAt) {
        profileEvent = event;
      }
    });
  }
}
