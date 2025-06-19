import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/entities/ndk_file.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:yana/nostr/upload/uploader.dart';
import 'package:yana/provider/metadata_provider.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/router_util.dart';
import 'package:yana/utils/string_util.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
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
  bool broadcasting = false;

  Duration REFRESH_METADATA_BEFORE_EDIT_DURATION = const Duration(minutes: 5);

  String getText(String? str) {
    return str ?? "";
  }

  Widget loader(String text) {
    var themeData = Theme.of(context);
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(text,
          style: TextStyle(
              color: themeData.textTheme.bodyMedium!.color, decoration: TextDecoration.none, fontFamily: 'Geist', fontWeight: FontWeight.normal, fontSize: 20)),
      const SizedBox(height: 50),
      SpinKitFadingCircle(
        color: themeData.textTheme.bodyMedium!.color,
        size: 100.0,
      )
    ]);
  }

  @override
  Widget doBuild(BuildContext context) {
    if (broadcasting) {
      return loader("Broadcasting metadata to relays...");
    }
    var _metadataProvider = Provider.of<MetadataProvider>(context);

    var s = I18n.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var mainColor = themeData.primaryColor;
    var textColor = themeData.textTheme.bodyMedium!.color;

    return FutureBuilder<Metadata?>(
        future: Future(() async {
          Metadata? cached = metadata ?? await metadataProvider.getMetadata(loggedUserSigner!.getPublicKey());
          if (cached != null &&
              cached.refreshedTimestamp != null &&
              cached.refreshedTimestamp! > (DateTime.now().subtract(REFRESH_METADATA_BEFORE_EDIT_DURATION).millisecondsSinceEpoch ~/ 1000)) {
              metadata = cached;
          } else {
            EasyLoading.show(status: "Refreshing metadata from relays...", maskType: EasyLoadingMaskType.black, dismissOnTap: true);
            await ndk.metadata.loadMetadata(loggedUserSigner!.getPublicKey(), forceRefresh: true).then(
              (metadata) {
                metadata ??= Metadata(pubKey: loggedUserSigner!.getPublicKey());
                EasyLoading.dismiss();
                return this.metadata;
              },
            ).timeout(const Duration(seconds: 6), onTimeout: () {
              metadata ??= Metadata(pubKey: loggedUserSigner!.getPublicKey(), updatedAt: Helpers.now);
              EasyLoading.dismiss();
              return metadata;
            });
          }
          return metadata;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            EasyLoading.dismiss();
            metadata = snapshot.data;

            displayNameController.text = getText(metadata!.displayName);
            nameController.text = getText(metadata!.name);
            aboutController.text = getText(metadata!.about);
            pictureController.text = getText(metadata!.picture);
            bannerController.text = getText(metadata!.banner);
            websiteController.text = getText(metadata!.website);
            nip05Controller.text = getText(metadata!.nip05);
            lud16Controller.text = getText(metadata!.lud16);
            lud06Controller.text = getText(metadata!.lud06);

            var submitBtn = TextButton(
              onPressed: profileSave,
              style: const ButtonStyle(),
              child: Text(
                s.Submit,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            );

            Color? appbarBackgroundColor = Colors.transparent;
            var appBar = Appbar4Stack(
              backgroundColor: appbarBackgroundColor,
              // title: appbarTitle,
              action: Container(
                margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                child: submitBtn,
              ),
            );

            var margin = const EdgeInsets.only(bottom: Base.BASE_PADDING);
            var padding = const EdgeInsets.only(left: 20, right: 20);

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
                  margin: const EdgeInsets.only(
                    left: Base.BASE_PADDING_HALF,
                    right: Base.BASE_PADDING_HALF,
                  ),
                  child: const Text(" @ "),
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
                decoration: InputDecoration(labelText: s.Lud16, hintText: "walletname@walletservice.com"),
              ),
            ));

            // list.add(Container(
            //   margin: margin,
            //   padding: padding,
            //   child: TextField(
            //     controller: lud06Controller,
            //     decoration: InputDecoration(labelText: "Lnurl"),
            //   ),
            // ));

            return Scaffold(
              body: Stack(
                children: [
                  Container(
                    width: mediaDataCache.size.width,
                    height: mediaDataCache.size.height - mediaDataCache.padding.top,
                    margin: EdgeInsets.only(top: mediaDataCache.padding.top),
                    child: Container(
                      color: cardColor,
                      padding: EdgeInsets.only(top: mediaDataCache.padding.top + Base.BASE_PADDING),
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
          return Container();
        });
  }

  Future<void> pickPicture() async {
    var filepaths = await pickImageAndUpload();
    for (final filepath in filepaths) {
      if (StringUtil.isNotBlank(filepath)) {
        pictureController.text = filepath!;
      }
    }
  }

  Future<void> pickBanner() async {
    var filepaths = await pickImageAndUpload();
    for (final filepath in filepaths) {
      if (StringUtil.isNotBlank(filepath)) {
        bannerController.text = filepath!;
      }
    }
  }

  Future<List<String?>> pickImageAndUpload() async {
    if (PlatformUtil.isWeb()) {
      // TODO ban image update at web temp
      return [];
    }

    var filepaths = await Uploader.pick(context);
    for (final filepath in filepaths) {
      if (filepath!=null) {
        File file = File(filepath);
        final bytes = await file.readAsBytes();
        final mimeType = lookupMimeType(file.path);
        final filename = file.path.split('/').last;
        if (mimeType == null || mimeType.isEmpty) {
          throw Exception("No mime type found");
        }
        final userServerList = await ndk.blossomUserServerList.getUserServerList(pubkeys: [loggedUserSigner!.getPublicKey()]);
        final uploadResponse = await ndk.files.upload(
          file: NdkFile(data: bytes, mimeType: mimeType),
          serverUrls: userServerList ?? DEFAULT_BLOSSOM_SERVERS
        );
      }
    }
    return filepaths;
  }

  void profileSave() async {
    setState(() {
      broadcasting = true;
    });
    metadata!.displayName = displayNameController.text;
    metadata!.name = nameController.text;
    metadata!.about = aboutController.text;
    metadata!.picture = pictureController.text;
    metadata!.banner = bannerController.text;
    metadata!.website = websiteController.text;
    metadata!.nip05 = nip05Controller.text;
    metadata!.lud16 = lud16Controller.text;
    metadata!.lud06 = lud06Controller.text;

    await ndk.metadata.broadcastMetadata(metadata!, specificRelays: myOutboxRelaySet!.urls);
    metadataProvider.notifyListeners();
    setState(() {
      broadcasting = false;
    });

    context.pop();
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
