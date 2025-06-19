import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/connection_source.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/entities/nip_01_event.dart';
import 'package:ndk/domain_layer/entities/relay.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/list_transactions_response.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:yana/main.dart';
import 'package:yana/provider/nwc_provider.dart';
import 'package:yana/provider/setting_provider.dart';
import 'package:yana/router/wallet/payment_component.dart';
import 'package:yana/router/wallet/transaction_item_component.dart';
import 'package:yana/utils/base.dart';
import 'package:yana/config/app_features.dart';

import '../../../ui/appbar4stack.dart';
import '../../nostr/client_utils/keys.dart';
import '../../nostr/nip19/nip19.dart';
import '../../nostr/nip19/nip19_tlv.dart';
import '../../provider/data_util.dart';
import '../../ui/button.dart';
import '../../utils/index_taps.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';
import 'bitcoin_amount.dart';

class WalletRouter extends StatefulWidget {
  final bool showAppBar;

  const WalletRouter({super.key, this.showAppBar = true});

  @override
  State<StatefulWidget> createState() {
    return _WalletRouter();
  }
}

class _WalletRouter extends State<WalletRouter> with ProtocolListener {
  TextEditingController nwcInputController = TextEditingController();

  ScrollController scrollController = ScrollController();
  PanelController panelController = PanelController();

  TransactionResult? transactionDetails;

  String formatBitcoinNumber(double bitcoin) {
    // Convert the number to a string with 2 decimal places
    String bitcoinString = bitcoin.toStringAsFixed(2);

    // Split the string into parts before and after the decimal point
    List<String> parts = bitcoinString.split('.');

    // Add spaces every three digits before the decimal point
    String formattedIntegerPart = parts[0].splitMapJoin(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        onMatch: (m) => '${m[1]} ',
        onNonMatch: (n) => n);

    // Combine the formatted integer part and the decimal part with 1 space
    String formattedBitcoin = '$formattedIntegerPart.${parts[1]}';

    return formattedBitcoin;
  }

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
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
          setState(() {});
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
            followEventProvider?.clear();
            followNewEventProvider?.clear();
            await settingProvider.addAndChangeKey(priv, true, false,
                updateUI: false);
            String publicKey = getPublicKey(priv);
            ndk.accounts.loginPrivateKey(pubkey: publicKey, privkey: priv);

            await initRelays(newKey: true);
            followEventProvider?.loadCachedFeed();

            newAccount = true;
            firstLogin = true;
            indexProvider.setCurrentTap(IndexTaps.FOLLOW);
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
        context.go(RouterPath.WALLET_SEND, extra: url.split(":").last);
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
            context.go(RouterPath.USER, extra: key);
          } else if (Nip19.isNoteId(key)) {
            // block
            if (key.length > Nip19.NOTEID_LENGTH) {
              otherStr = key.substring(Nip19.NOTEID_LENGTH);
              key = key.substring(0, Nip19.NOTEID_LENGTH);
            }
            key = Nip19.decode(key);
            context.go(RouterPath.THREAD_DETAIL, extra: key);
          } else if (NIP19Tlv.isNprofile(key)) {
            var nprofile = NIP19Tlv.decodeNprofile(key);
            if (nprofile != null) {
              // inline
              // mention user
              context.go(RouterPath.USER, extra: nprofile.pubkey);
            }
          } else if (NIP19Tlv.isNrelay(key)) {
            var nrelay = NIP19Tlv.decodeNrelay(key);
            String? url = nrelay != null ? cleanRelayUrl(nrelay.addr) : null;
            if (url != null) {
              // inline
              Relay relay =
                  Relay(url: url, connectionSource: ConnectionSource.explicit);
              context.go(RouterPath.RELAY_INFO, extra: relay);
            }
          } else if (NIP19Tlv.isNevent(key)) {
            var nevent = NIP19Tlv.decodeNevent(key);
            if (nevent != null) {
              if (nevent.relays != null && nevent.relays!.isNotEmpty) {
                // TODO allowReconnectRelays is false, WTF?
                // await ndk.relays.reconnectRelays(nevent.relays!);
              }
              context.go(RouterPath.THREAD_DETAIL, extra: nevent.id);
            }
          } else if (NIP19Tlv.isNaddr(key)) {
            var naddr = NIP19Tlv.decodeNaddr(key);
            if (naddr != null) {
              if (StringUtil.isNotBlank(naddr.id) &&
                  naddr.kind == Nip01Event.kTextNodeKind) {
                context.go(RouterPath.THREAD_DETAIL, extra: naddr.id);
              } else if (StringUtil.isNotBlank(naddr.author) &&
                  naddr.kind == Metadata.kKind) {
                context.go(RouterPath.USER, extra: naddr.author);
              }
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    bool wasOpen = panelController.isPanelOpen;
    if (wasOpen) {
      panelController.close();
    }
    return wasOpen;
  }

  @override
  Widget build(BuildContext context) {
    var _nwcProvider = Provider.of<NwcProvider>(context);
    var _settingsProvider = Provider.of<SettingProvider>(context);
    mediaDataCache.update(context);

    var themeData = Theme.of(context);
    bool albygoing = false;

    Color? appbarBackgroundColor = themeData.canvasColor;

    var appBar = Appbar4Stack(
      title: Selector<NwcProvider, bool>(
        builder: (context, isConnected, child) {
          String title = "Connect a Wallet";
          if (isConnected) {
            title = "Nostr Wallet Connect";
          }
          return Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Geist.Mono",
                fontSize: 20,
              ),
            ),
          );
        },
        selector: (context, _provider) {
          return _provider.isConnected;
        },
      ),
      backgroundColor: appbarBackgroundColor,
    );

    Widget main = Selector<NwcProvider, bool>(
      builder: (context, isConnected, child) {
        List<Widget> list = [];
        if (isConnected) {
          list.add(const SizedBox(
            height: 40,
          ));
          list.add(Selector<NwcProvider, int?>(
            builder: (context, balance, child) {
              if (balance != null) {
                double? fiatAmount = fiatCurrencyRate != null
                    ? ((balance / 100000000) * fiatCurrencyRate!["value"] * 100)
                            .truncateToDouble() /
                        100
                    : null;

                return BitcoinAmount(
                    fiatAmount: fiatAmount,
                    fiatUnit: fiatCurrencyRate != null
                        ? fiatCurrencyRate!["unit"]
                        : null,
                    balance: balance);
              }
              return Container();
            },
            selector: (context, _provider) {
              return _provider.getBalance;
            },
          ));
          list.add(const SizedBox(
            height: 20,
          ));
          if (_nwcProvider.canPayInvoice ||
              (nwcProvider?.canMakeInvoice ?? false)) {
            list.add(Container(
                margin: const EdgeInsets.all(Base.BASE_PADDING),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _nwcProvider.canMakeInvoice
                        ? Expanded(
                            child: Button(
                                before: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: const Icon(Icons.call_received,
                                        color: Colors.white)),
                                fontSize: 20,
                                text: "Receive",
                                height: 70,
                                // before: const Icon(Icons.call_received_rounded),
                                onTap: () async {
                                  Metadata? metadata =
                                      await metadataProvider.getMetadata(
                                          loggedUserSigner!.getPublicKey());
                                  if (metadata != null &&
                                      StringUtil.isNotBlank(metadata.lud16)) {
                                    context.go(RouterPath.WALLET_RECEIVE,
                                        extra: metadata);
                                  } else {
                                    context.go(
                                        RouterPath.WALLET_RECEIVE_INVOICE,
                                        extra: metadata);
                                  }
                                }))
                        : Container(),
                    _nwcProvider.canMakeInvoice && _nwcProvider.canPayInvoice
                        ? const SizedBox(width: 24)
                        : Container(),
                    _nwcProvider.canPayInvoice
                        ? Expanded(
                            child: Button(
                                before: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: const Icon(
                                      Icons.call_made,
                                      color: Colors.white,
                                    )),
                                text: "Send",
                                fontSize: 20,
                                height: 70,
                                // before: const Icon(Icons.call_made_rounded),
                                onTap: () async {
                                  context.go(RouterPath.WALLET_SEND);
                                }))
                        : Container()
                  ],
                )));
          }

          if (nwcProvider?.canListTransaction ?? false) {
            list.add(const SizedBox(height: 16));
            list.add(Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      // If canListTransaction is true, nwcProvider should not be null here.
                      // However, to be safe with the call itself:
                      ListTransactionsResponse? response = await nwcProvider
                          ?.listTransactions(limit: 20, unpaid: false);
                      if (response != null) {
                        _nwcProvider.cachedListTransactionsResponse = response;
                      }
                    },
                    child: Selector<NwcProvider, List<TransactionResult>?>(
                        builder: (context, transactions, child) {
                      return transactions != null && transactions.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                // if (index == transactions.length) {
                                //   return GestureDetector(
                                //       onTap: () {
                                //         context.go(RouterPath.WALLET_TRANSACTIONS);
                                //       },
                                //       // child:
                                //       // Expanded(
                                //       child: MouseRegion(
                                //           cursor: SystemMouseCursors.click,
                                //           child: Container(
                                //             margin: const EdgeInsets.only(top: Base.BASE_PADDING),
                                //             padding: const EdgeInsets.all(Base.BASE_PADDING),
                                //             height: 60.0,
                                //             // decoration: const BoxDecoration(
                                //             //     gradient: LinearGradient(
                                //             //         colors: [Color(0xffFFDE6E), Colors.orange]),
                                //             //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                //             child: const Center(
                                //                 child: Row(
                                //                     mainAxisAlignment: MainAxisAlignment.center,
                                //                     children: [
                                //                       Text('List all transactions >>',
                                //                           style: TextStyle(color: Colors.white))
                                //                     ])),
                                //           ))
                                //     // ),
                                //   );
                                // }
                                return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        transactionDetails =
                                            transactions[index];
                                      });
                                      await panelController.open();
                                    },
                                    child: TransactionItemComponent(
                                        transaction: transactions[index]));
                              },
                              itemCount: transactions.length,
                            )
                          : Container();
                    }, selector: (context, _provider) {
                      return _provider.transactions;
                    }))));
            // list.add(RefreshIndicator(
            //   onRefresh: () async {
            //     nwcProvider.requestListTransactions();
            //   },
            //   child: Selector<NwcProvider, List<WalletTransaction>>(
            //     builder: (context, transactions, child) {
            //       return transactions!=null && transactions.isNotEmpty ? Column(
            //         children: transactions.take(10).map((t) {
            //           bool outgoing = t.type == "outgoing";
            //           var time = "";
            //           try {
            //             time = t.settled_at!=null?GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(t.settled_at!*1000)):"";
            //             // 2023-12-21T01:36:39.97766341Z
            //           } catch (e) {}
            //           return Row(children: [
            //             Text(outgoing ? ' ↑ ' : ' ↓ ', style: TextStyle(color: outgoing? Colors.red:Colors.green),),
            //             Text(Helpers.isNotBlank(t.description)?t.description!:(outgoing?" Sent ":" Received ")),
            //             Text(" ${outgoing? "-": "+"}${(t.amount / 1000).toInt()} ", style: TextStyle(color: outgoing? Colors.red:Colors.green)),
            //             Text("${time}")
            //           ]);
            //         }).toList(),
            //       ) : Container();
            //     },
            //   selector: (context, _provider) {
            //     return _provider.transactions;
            //   }
            // )));
          }
          // list.add();
        } else {
          list.add(Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          // height: 112,
                          padding: const EdgeInsets.only(bottom: 24),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Connect Wallet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w700,
                                    height: 0.06,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                // width: double.infinity,
                                child: Text(
                                  'Connect your bitcoin lightning wallet with NWC for better zapping experience.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF7A7D81),
                                    fontSize: 16,
                                    fontFamily: 'Geist',
                                    fontWeight: FontWeight.w400,
                                    // height: 0.09,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset("assets/imgs/albygo.png"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Button(
                              text: "Alby Go",
                              fontSize: 18,
                              width: 200,
                              onTap: () async {
                                albygoing = true;
                                if (Platform.isAndroid) {
                                  AndroidIntent intent = AndroidIntent(
                                    action: 'action_view',
                                    data:
                                        "nostrnwc://bla?appname=Yana\&appicon=https%3A%2F%2Fyana.do%2Fimages%2Flogo-new.png\&callback=yana%3A%2F%2F",
                                  );
                                  await intent.launch();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset("assets/imgs/nwc.png"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Button(
                              text: "NWC manual",
                              fontSize: 18,
                              width: 200,
                              onTap: () {
                                context.go(RouterPath.NWC);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
          // list.add(GestureDetector(
          //     onTap: () {
          //       RouterUtil.router(context, RouterPath.NWC);
          //     },
          //     // child:
          //     // Expanded(
          //     child: MouseRegion(
          //         cursor: SystemMouseCursors.click,
          //         child: Container(
          //           margin: const EdgeInsets.only(top: Base.BASE_PADDING),
          //           padding: const EdgeInsets.all(Base.BASE_PADDING),
          //           height: 60.0,
          //           decoration: const BoxDecoration(
          //               gradient: LinearGradient(
          //                   colors: [Color(0xffFFDE6E), Colors.orange]),
          //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //           child: Center(
          //               child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                 Container(
          //                     margin: const EdgeInsets.only(
          //                         right: Base.BASE_PADDING),
          //                     child: Image.asset("assets/imgs/nwc.png")),
          //                 const Text('Nostr Wallet Connect',
          //                     style: TextStyle(color: Colors.black))
          //               ])),
          //         ))
          //     // ),
          //     ));
          // list.add(Row(children: [
          //   Expanded(
          //       child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: Container(
          //         margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
          //         padding: const EdgeInsets.all(Base.BASE_PADDING),
          //         height: 60.0,
          //         decoration: const BoxDecoration(
          //             gradient: LinearGradient(colors: [Color(0xff8bd7f9), Color(0xff174697)]), borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //         child: Center(
          //             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //           Container(
          //               margin: const EdgeInsets.only(right: Base.BASE_PADDING),
          //               child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: Image.asset("assets/imgs/lndhub.png"))),
          //           const Text('LndHub Connect', style: TextStyle(color: Colors.white)),
          //           Text('  (soon)', style: TextStyle(color: themeData.hintColor, fontFamily: "Geist", fontSize: 12))
          //         ]))),
          //   )),
          // ]));
          // list.add(Row(children: [
          //   Expanded(
          //       child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: Container(
          //         margin: const EdgeInsets.only(top: Base.BASE_PADDING * 2),
          //         padding: const EdgeInsets.all(Base.BASE_PADDING),
          //         height: 60.0,
          //         decoration: const BoxDecoration(
          //             gradient: LinearGradient(colors: [Color(0xff0f0f0f), Color(0xff0f0f0f)]), borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //         child: Center(
          //             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //           Container(
          //               margin: const EdgeInsets.only(right: Base.BASE_PADDING),
          //               child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: Image.asset("assets/imgs/greenlight.png"))),
          //           const Text('', style: TextStyle(color: Colors.white)),
          //           Text('  (soon)', style: TextStyle(color: themeData.hintColor, fontFamily: "Geist", fontSize: 12))
          //         ]))),
          //   )),
          // ]));

          // TODO Lndhub wallet connect

          // const Text("Wallet Connect URI (NWC)"),
          // Container(
          //   margin: const EdgeInsets.only(left: Base.BASE_PADDING),
          //   child: Image.asset("assets/imgs/alby.png", width: 30, height: 30),
          // ),
          // Container(
          //     margin: const EdgeInsets.only(left: Base.BASE_PADDING),
          //     child: GestureDetector(
          //         behavior: HitTestBehavior.translucent,
          //         onTap: scanNWC,
          //         child: Icon(Icons.qr_code_scanner,
          //             size: 25, color: themeData.iconTheme.color)))
        }
        return Column(
          // mainAxisSize: MainAxisSize.min,
          children: list,
        );
      },
      selector: (context, _provider) {
        return _provider.isConnected;
      },
    );

    var appBarNew = AppBar(
      toolbarHeight: 70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: themeData.appBarTheme.backgroundColor,
      leading: AppFeatures.isWalletOnly? Container(): GestureDetector(
          onTap: () {
            context.go(RouterPath.INDEX);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back_ios,
              color: themeData.hintColor,
            ),
          )),
      title: const Text("Wallet",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Geist.Mono",
            fontSize: 20,
          )),
      actions: [barOptions()],
    );

    return Scaffold(
        appBar: widget.showAppBar ? appBarNew : null,
        backgroundColor: themeData.cardColor,
        body: Stack(children: [
          main,
          SlidingUpPanel(
            controller: panelController,
            backdropEnabled: true,
            color: themeData.appBarTheme.backgroundColor!,
            minHeight: 0,
            maxHeight: mediaDataCache.size.height - 300,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            panel: PaymentDetailsComponent(
              paid: transactionDetails,
            ),
          )
        ]));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: mediaDataCache.size.width,
            height: mediaDataCache.size.height - mediaDataCache.padding.top,
            margin: EdgeInsets.only(top: mediaDataCache.padding.top),
            child: Container(
              color: themeData.cardColor,
              child: Center(
                child:
                    //main
                    Container(
                        width: mediaDataCache.size.width * 0.8, child: main),
              ),
            ),
          ),
          Positioned(
            top: mediaDataCache.padding.top,
            child: Container(
              width: mediaDataCache.size.width,
              child: appBar,
            ),
          ),
        ],
      ),
    );
  }

  Widget barOptions() {
    return (nwcProvider?.isConnected ?? false)
        ? Container(
            margin: const EdgeInsets.all(5),
            child: PopupMenuButton<String>(
                icon: Image.asset("assets/imgs/settings.png",
                    width: 24, height: 24),
                tooltip: "settings",
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> list = [
                    const PopupMenuItem(
                        value: "settings", child: Text("Settings")),
                  ];
                  if (nwcProvider?.isConnected ?? false) {
                    list.add(
                      const PopupMenuItem(
                        value: "disconnect",
                        child: Text("Disconnect wallet"),
                      ),
                    );
                  }
                  return list;
                },
                onSelected: (value) {
                  if (value == "disconnect") {
                    setState(() {
                      nwcProvider?.disconnect();
                    });
                  } else if (value == "settings") {
                    context.push(RouterPath.SETTINGS_WALLET);
                  }
                }))
        : Container();
  }
}
