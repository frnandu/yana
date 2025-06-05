import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/entities.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../nostr/nip57/zap_action.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../utils/router_util.dart';
import '../../utils/string_util.dart';
import '../content/content_str_link_component.dart';

class GenLnbcComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GenLnbcComponent();
  }
}

class _GenLnbcComponent extends State<GenLnbcComponent> {
  late TextEditingController controller;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    commentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
        future: metadataProvider.getMetadata(loggedUserSigner!.getPublicKey()),
        builder: (context, snapshot) {
          var metadata = snapshot.data;
          var themeData = Theme.of(context);
          Color cardColor = themeData.cardColor;
          var mainColor = themeData.primaryColor;
          var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
          var s = I18n.of(context);
          if (metadata == null || (StringUtil.isBlank(metadata.lud06) && StringUtil.isBlank(metadata.lud16))) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.Lnurl_and_Lud16_can_t_found,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(Base.BASE_PADDING),
                      child: ContentStrLinkComponent(
                        str: s.Add_now,
                        onTap: () async {
                          await RouterUtil.router(context, RouterPath.PROFILE_EDITOR, metadata);
                          metadataProvider.update(loggedUserSigner!.getPublicKey());
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          List<Widget> list = [];

          // list.add(Container(
          //   margin: EdgeInsets.only(bottom: Base.BASE_PADDING),
          //   child: Text(
          //     s.Input_Sats_num_to_gen_lightning_invoice,
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: titleFontSize,
          //     ),
          //   ),
          // ));

          list.add(Container(
            margin: EdgeInsets.only(bottom: Base.BASE_PADDING),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 1,
              autofocus: true,
              decoration: InputDecoration(
                hintText: s.Input_Sats_num,
                border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
              ),
            ),
          ));

          list.add(Container(
            child: TextField(
              controller: commentController,
              minLines: 1,
              maxLines: 1,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "${s.Input_Comment} (${s.Optional})",
                border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
              ),
            ),
          ));

          list.add(Expanded(child: Container()));

          list.add(Container(
            margin: EdgeInsets.only(
              top: Base.BASE_PADDING,
              bottom: 6,
            ),
            child: Ink(
              decoration: BoxDecoration(color: mainColor),
              child: InkWell(
                onTap: () {
                  _onConfirm(metadata.pubKey!);
                },
                highlightColor: mainColor.withOpacity(0.2),
                child: Container(
                  color: mainColor,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    I18n.of(context).Confirm,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ));

          var main = Container(
            padding: EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
              color: cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: list,
            ),
          );

          return main;
        });
  }

  Future<void> _onConfirm(String pubkey) async {
    var text = controller.text;
    var num = int.tryParse(text);
    if (num == null) {
      EasyLoading.show(status: I18n.of(context).Number_parse_error);
      return;
    }

    var comment = commentController.text;
    log("comment $comment");
    var lnbcStr = await ZapAction.genInvoiceCode(context, num, pubkey, comment: comment);
    if (StringUtil.isNotBlank(lnbcStr)) {
      RouterUtil.back(context, lnbcStr);
    }
  }
}
