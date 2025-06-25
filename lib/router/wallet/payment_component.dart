import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ndk/domain_layer/entities/metadata.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/list_transactions_response.dart';

import '../../main.dart';
import '../../ui/name_component.dart';
import '../../ui/user_pic_component.dart';
import '../../utils/base.dart';
import '../../utils/router_path.dart';
import '../../utils/string_util.dart';

class PaymentDetailsComponent extends StatefulWidget {
  final TransactionResult? paid;

  const PaymentDetailsComponent({super.key, this.paid});

  @override
  State<StatefulWidget> createState() {
    return _PaymentDetailsComponent();
  }
}

var dateFormater = DateFormat("yyyy-MM-dd HH:mm");

class _PaymentDetailsComponent extends State<PaymentDetailsComponent> {
  @override
  Widget build(BuildContext context) {
    if (widget.paid == null) {
      return Container();
    }
    var themeData = Theme.of(context);

    double? fiatAmount = fiatCurrencyRate != null
        ? ((widget.paid!.amount / 100000000000) * fiatCurrencyRate!["value"])
        : null;
    // int feesPaid = (paid!.feesPaid / 1000).round();
    int amount = (widget.paid!.amount / 1000).round();
    // TODO: implement build
    String? zapperPubKey = widget.paid!.zapperPubKey;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          const SizedBox(
            height: 18.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.paid!.isIncoming ? "Received" : "Paid",
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 18.0,
          ),
          Divider(color: Colors.grey[800]),
          zapperPubKey != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'from: ',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                    ),
                    FutureBuilder<Metadata?>(
                        future: metadataProvider.getMetadata(zapperPubKey),
                        builder: (context, snapshot) {
                          var metadata = snapshot.data;
                          return GestureDetector(
                              onTap: () {
                                context.push(RouterPath.USER,
                                    extra: zapperPubKey);
                              },
                              child: NameComponent(
                                pubkey: zapperPubKey,
                                metadata: metadata,
                              ));
                        })
                  ],
                )
              : Container(),
          const SizedBox(
            height: 18.0,
          ),
          zapperPubKey != null
              ? GestureDetector(
                  onTap: () {
                    context.go(
                      RouterPath.USER,
                      extra: zapperPubKey,
                    );
                  },
                  child: UserPicComponent(
                    pubkey: zapperPubKey,
                    width: 100,
                  ))
              : Container(
                  decoration: ShapeDecoration(
                    color: widget.paid!.isIncoming
                        ? const Color(0x4f47A66D)
                        : const Color(0x4fE26842),
                    shape: const CircleBorder(side: BorderSide.none),
                  ),
                  padding: const EdgeInsets.all(Base.BASE_PADDING),
                  child: Icon(
                    widget.paid!.isIncoming
                        ? Icons.call_received
                        : Icons.call_made,
                    color: widget.paid!.isIncoming
                        ? const Color(0xFF47A66D)
                        : const Color(0xFFE26842),
                    size: 100.0,
                  )),
          const SizedBox(height: 20.0),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "${widget.paid!.isIncoming ? '+' : '-'}$amount",
                  style: TextStyle(
                      fontSize: 28.0,
                      color: widget.paid!.isIncoming
                          ? const Color(0xff47A66D)
                          : const Color(0xFFE26842)),
                ),
                TextSpan(
                  text: ' sat${amount > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 24.0, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            fiatAmount == null || fiatAmount < 0.01
                ? "< ${fiatCurrencyRate?["unit"]}0.01"
                : "${fiatCurrencyRate?["unit"]}${fiatAmount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 22.0, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20.0),

          // Scrollable details below
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  widget.paid!.createdAt > 0
                      ? Row(
                          children: [
                            SizedBox(
                                width: mediaDataCache.size.width / 2 - 30,
                                child: Text("Date & Time",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[700]))),
                            Text(dateFormater.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.paid!.createdAt * 1000)))
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                        width: mediaDataCache.size.width / 2 - 30,
                        child: Text("Description",
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.grey[700]))),
                    Flexible(
                        child: Text(
                      StringUtil.isNotBlank(widget.paid!.description)
                          ? widget.paid!.description!
                          : 'None',
                      style: StringUtil.isBlank(widget.paid!.description)
                          ? TextStyle(fontSize: 16.0, color: Colors.grey[700])
                          : null,
                    ))
                  ]),
                  const SizedBox(
                    height: 5,
                  ),
                  widget.paid!.feesPaid! > 0
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: mediaDataCache.size.width / 2 - 30,
                                  child: Text("Fee",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey[700]))),
                              Flexible(
                                  child: Text(
                                "${(widget.paid!.feesPaid! / 1000).toStringAsFixed(0)} sats",
                              ))
                            ])
                      : Container(),
                  const SizedBox(
                    height: 5,
                  ),
                  StringUtil.isNotBlank(widget.paid!.paymentHash)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: mediaDataCache.size.width / 2 - 30,
                                  child: Text("Payment Hash",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey[700]))),
                              Flexible(
                                  child: Text(
                                widget.paid!.paymentHash,
                              ))
                            ])
                      : Container(),
                  const SizedBox(
                    height: 5,
                  ),
                  StringUtil.isNotBlank(widget.paid!.preimage)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: mediaDataCache.size.width / 2 - 30,
                                  child: Text("Payment Preimage",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey[700]))),
                              Flexible(
                                  child: GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(
                                                text: widget.paid!.preimage!))
                                            .then((_) {
                                          print("a");
                                        });
                                      },
                                      child: SelectableText(
                                        widget.paid!.preimage!,
                                      )))
                            ])
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
