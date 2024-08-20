import 'dart:convert';

import 'package:ndk/shared/nips/nip04/nip04.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yana/ui/cust_state.dart';
import 'package:yana/ui/nip07_dialog.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/utils/base_consts.dart';
import 'package:yana/provider/setting_provider.dart';
import 'package:yana/provider/webview_provider.dart';
import 'package:yana/utils/platform_util.dart';
import 'package:yana/utils/string_util.dart';

import '../nostr/nip07/nip07_methods.dart';
import '../i18n/i18n.dart';
import '../main.dart';

class WebViewRouter extends StatefulWidget {
  String url;

  WebViewRouter({super.key, required this.url});

  static void open(BuildContext context, String link) {
    if (PlatformUtil.isTableMode()) {
      launchUrl(Uri.parse(link));
      return;
    }
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return WebViewRouter(url: link);
    // }));
    webViewProvider.open(link);
  }

  @override
  State<StatefulWidget> createState() {
    return _WebViewRouter();
  }
}

class _WebViewRouter extends CustState<WebViewRouter> {
  WebViewController _controller = WebViewController();

  String? url;

  double btnWidth = 40;

  void nip07Reject(String resultId, String contnet) {
    var script = "window.nostr.reject(\"$resultId\", \"${contnet}\");";
    _controller.runJavaScript(script);
  }

  @override
  void initState() {
    super.initState();
    _controller.addJavaScriptChannel(
      "Yana_JS_getPublicKey",
      onMessageReceived: (jsMsg) async {
        var jsonObj = jsonDecode(jsMsg.message);
        var resultId = jsonObj["resultId"];

        var confirmResult =
            await NIP07Dialog.show(context, NIP07Methods.getPublicKey);
        if (confirmResult == true) {
          var pubkey = loggedUserSigner!.getPublicKey();
          var script = "window.nostr.callback(\"$resultId\", \"$pubkey\");";
          _controller.runJavaScript(script);
        } else {
          nip07Reject(resultId, I18n.of(context).Forbid);
        }
      },
    );
    _controller.addJavaScriptChannel(
      "Yana_JS_signEvent",
      onMessageReceived: (jsMsg) async {
        var jsonObj = jsonDecode(jsMsg.message);
        var resultId = jsonObj["resultId"];
        var content = jsonObj["msg"];

        var confirmResult = await NIP07Dialog.show(
            context, NIP07Methods.signEvent,
            content: content);

        if (confirmResult == true) {
          try {
            var eventObj = jsonDecode(content);
            var tags = eventObj["tags"];
            Nip01Event event = Nip01Event(
                pubKey: loggedUserSigner!.getPublicKey(),
                kind: eventObj["kind"],
                tags: tags ?? [],
                content: eventObj["content"]
            );
            loggedUserSigner!.sign(event);

            var eventResultStr = jsonEncode(event.toJson());
            // TODO this method to handle " may be error
            eventResultStr = eventResultStr.replaceAll("\"", "\\\"");
            var script =
                "window.nostr.callback(\"$resultId\", JSON.parse(\"$eventResultStr\"));";
            _controller.runJavaScript(script);
          } catch (e) {
            nip07Reject(resultId, I18n.of(context).Sign_fail);
          }
        } else {
          nip07Reject(resultId, I18n.of(context).Forbid);
        }
      },
    );
    _controller.addJavaScriptChannel(
      "Yana_JS_getRelays",
      onMessageReceived: (jsMsg) async {
        var jsonObj = jsonDecode(jsMsg.message);
        var resultId = jsonObj["resultId"];

        var comfirmResult =
            await NIP07Dialog.show(context, NIP07Methods.getRelays);
        if (comfirmResult == true) {
          var relayMaps = {};
          var relayAddrs = myInboxRelaySet!.urls.toList()..addAll(myOutboxRelaySet!.urls);
          for (var relayAddr in relayAddrs) {
            relayMaps[relayAddr] = {"read": true, "write": true};
          }
          var resultStr = jsonEncode(relayMaps);
          resultStr = resultStr.replaceAll("\"", "\\\"");
          var script =
              "window.nostr.callback(\"$resultId\", JSON.parse(\"$resultStr\"));";
          _controller.runJavaScript(script);
        } else {
          nip07Reject(resultId, I18n.of(context).Forbid);
        }
      },
    );
    _controller.addJavaScriptChannel(
      "Yana_JS_nip04_encrypt",
      onMessageReceived: (jsMsg) async {
        var jsonObj = jsonDecode(jsMsg.message);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var plaintext = msg["plaintext"];

          var comfirmResult = await NIP07Dialog.show(
              context, NIP07Methods.nip04_encrypt,
              content: plaintext);
          if (comfirmResult == true) {
            var resultStr = await loggedUserSigner!.encrypt(plaintext, pubkey);
            var script =
                "window.nostr.callback(\"$resultId\", \"$resultStr\");";
            _controller.runJavaScript(script);
          } else {
            nip07Reject(resultId, I18n.of(context).Forbid);
          }
        }
      },
    );
    _controller.addJavaScriptChannel(
      "Yana_JS_nip04_decrypt",
      onMessageReceived: (jsMsg) async {
        var jsonObj = jsonDecode(jsMsg.message);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var ciphertext = msg["ciphertext"];

          var comfirmResult = await NIP07Dialog.show(
              context, NIP07Methods.nip04_decrypt,
              content: ciphertext);
          if (comfirmResult == true) {
            var resultStr = await loggedUserSigner!.decrypt(ciphertext, pubkey);
            var script =
                "window.nostr.callback(\"$resultId\", \"$resultStr\");";
            _controller.runJavaScript(script);
          } else {
            nip07Reject(resultId, I18n.of(context).Forbid);
          }
        }
      },
    );
    _controller.setNavigationDelegate(NavigationDelegate(
      onWebResourceError: (error) {
        print(error);
      },
      onPageFinished: (url) {
        _controller.runJavaScript("""
window.nostr = {
_call(channel, message) {
    return new Promise((resolve, reject) => {
        var resultId = "callbackResult_" + Math.floor(Math.random() * 100000000);
        var arg = {"resultId": resultId};
        if (message) {
            arg["msg"] = message;
        }
        var argStr = JSON.stringify(arg);
        channel.postMessage(argStr);
        window.nostr._requests[resultId] = {resolve, reject}
    });
},
_requests: {},
callback(resultId, message) {
    window.nostr._requests[resultId].resolve(message);
},
reject(resultId, message) {
    window.nostr._requests[resultId].reject(message);
},
async getPublicKey() {
    return window.nostr._call(Yana_JS_getPublicKey);
},
async signEvent(event) {
    return window.nostr._call(Yana_JS_signEvent, JSON.stringify(event));
},
async getRelays() {
    return window.nostr._call(Yana_JS_getRelays);
},
nip04: {
  async encrypt(pubkey, plaintext) {
    return window.nostr._call(Yana_JS_nip04_encrypt, {"pubkey": pubkey, "plaintext": plaintext});
  },
  async decrypt(pubkey, ciphertext) {
      return window.nostr._call(Yana_JS_nip04_decrypt, {"pubkey": pubkey, "ciphertext": ciphertext});
  },
},
};
""");
      },
    ));
  }

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var paddingTop = mediaDataCache.padding.top;
    var mainColor = themeData.primaryColor;
    var scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _webViewProvider = Provider.of<WebViewProvider>(context);

    if (url != null && widget.url != url) {
      url = widget.url;
      _controller.loadRequest(Uri.parse(widget.url));
    }

    var btnTopPosition = Base.BASE_PADDING + Base.BASE_PADDING_HALF;

    var main = WebViewWidget(
      controller: _controller,
    );

    AppBar? appbar;
    late Widget bodyWidget;
    if (_settingProvider.webviewAppbarOpen == OpenStatus.OPEN) {
      bodyWidget = main;
      appbar = AppBar(
        backgroundColor: mainColor,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios_new),
          onTap: handleBack,
        ),
        actions: [
          getMoreWidget(Container(
            height: btnWidth,
            width: btnWidth,
            margin: EdgeInsets.only(right: Base.BASE_PADDING),
            child: Icon(Icons.more_horiz),
            alignment: Alignment.center,
          ))
        ],
      );
    } else {
      var lefeBtn = GestureDetector(
        onTap: handleBack,
        child: Container(
          height: btnWidth,
          width: btnWidth,
          decoration: BoxDecoration(
            color: scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(btnWidth / 2),
          ),
          child: Icon(Icons.arrow_back_ios_new),
          alignment: Alignment.center,
        ),
      );

      bodyWidget = Container(
        margin: EdgeInsets.only(top: paddingTop),
        child: Stack(
          children: [
            main,
            Positioned(
              left: Base.BASE_PADDING,
              top: btnTopPosition,
              child: lefeBtn,
            ),
            Positioned(
              right: Base.BASE_PADDING,
              top: btnTopPosition,
              child: getMoreWidget(Container(
                height: btnWidth,
                width: btnWidth,
                decoration: BoxDecoration(
                  color: scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(btnWidth / 2),
                ),
                child: Icon(Icons.more_horiz),
                alignment: Alignment.center,
              )),
            ),
          ],
        ),
      );
    }

    if (_webViewProvider.showable) {
      bodyWidget = WillPopScope(
        child: bodyWidget,
        onWillPop: () async {
          await handleBack();
          return false;
        },
      );
    }

    return Scaffold(
      appBar: appbar,
      body: bodyWidget,
    );
  }

  Widget getMoreWidget(Widget icon) {
    var s = I18n.of(context);
    var themeData = Theme.of(context);

    return PopupMenuButton<String>(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: "copyCurrentUrl",
            child: Text(s.Copy_current_Url),
          ),
          PopupMenuItem(
            value: "copyInitUrl",
            child: Text(s.Copy_init_Url),
          ),
          PopupMenuItem(
            value: "openInBrowser",
            child: Text(s.Open_in_browser),
          ),
          PopupMenuItem(
            value: "hideBrowser",
            child: Text(s.Hide),
          ),
          PopupMenuItem(
            value: "close",
            child: Text(s.close),
          ),
        ];
      },
      onSelected: onPopupSelected,
      child: icon,
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    url = widget.url;
    _controller.loadRequest(Uri.parse(widget.url));
  }

  Future<void> onPopupSelected(String value) async {
    var url = await _controller.currentUrl();
    if (value == "copyCurrentUrl") {
      if (StringUtil.isNotBlank(url)) {
        _doCopy(url!);
      }
    } else if (value == "copyInitUrl") {
      _doCopy(widget.url);
    } else if (value == "openInBrowser") {
      var _url = Uri.parse(widget.url);
      launchUrl(_url, mode: LaunchMode.externalApplication);
    } else if (value == "hideBrowser") {
      webViewProvider.hide();
    } else if (value == "close") {
      webViewProvider.close();
    }
  }

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      EasyLoading.show(status: I18n.of(context).Copy_success);
    });
  }

  Future<void> handleBack() async {
    var canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      _controller.goBack();
    } else {
      // RouterUtil.back(context);
      webViewProvider.close();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.loadRequest(Uri.parse('about:blank'));
    // log("dispose!!!!");
  }
}
