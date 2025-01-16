import 'package:flutter/material.dart';
// import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:yana/provider/filter_provider.dart';
import 'package:yana/utils/router_util.dart';
import 'package:yana/utils/when_stop_function.dart';

import '../../i18n/i18n.dart';
import '../../main.dart';
import '../../models/currency.dart';
import '../../provider/relay_provider.dart';
import '../../provider/setting_provider.dart';
import '../../ui/confirm_dialog.dart';
import '../../ui/enum_selector_component.dart';
import '../../utils/base_consts.dart';
import '../../utils/rates.dart';
import '../../utils/router_path.dart';

class WalletSettingsRouter extends StatefulWidget {

  const WalletSettingsRouter({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SettingRouter();
  }
}

class _SettingRouter extends State<WalletSettingsRouter> with WhenStopFunction {

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var _settingProvider = Provider.of<SettingProvider>(context);
    var _relayProvider = Provider.of<RelayProvider>(context);
    var _filterProvider = Provider.of<FilterProvider>(context);

    var mainColor = themeData.primaryColor;
    var hintColor = themeData.hintColor;

    var s = I18n.of(context);

    List<Widget> list = [];

    list.add(SliverToBoxAdapter(
      child: Container(
        height: 30,
      ),
    ));

    List<AbstractSettingsTile> walletTiles = [];
    if (nwcProvider.isConnected) {
      walletTiles.add(SettingsTile.navigation(
        onPressed: (context) async {
          await pickFiatCurrency();
        },
        leading: const Icon(Icons.currency_exchange),
        trailing: Text(settingProvider.currency!.toUpperCase()),
        title: const Text("Choose Fiat Currency"),
      ));

      walletTiles.add(SettingsTile.navigation(
        trailing: const Text(""),
        onPressed: (context) async {
          var result = await ConfirmDialog.show(context, "Are you sure?");
          if (result == true) {
            setState(() {
              nwcProvider.disconnect();
            });
          }
        },
        leading: const Icon(Icons.remove_circle_outline),
        title: const Text("Disconnect Nostr Wallet Connect"),
      ));
    } else {
      walletTiles.add(SettingsTile.navigation(
        trailing: const Text(""),
        onPressed: (context) async {
          RouterUtil.router(context, RouterPath.WALLET);
        },
        leading: const Icon(Icons.wallet),
        title: const Text("Connect Nostr Wallet Connect"),
      ));
    }


    List<SettingsSection> sections = [];

    sections.add(SettingsSection(title: Text('Wallet'), tiles: walletTiles));

    SettingsList settingsList = SettingsList(
        applicationType: ApplicationType.both,
        // contentPadding: const EdgeInsets.only(top: Base.BASE_PADDING),
        sections: sections);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: Text(
          "Wallet Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
      ),
      body:
          // CustomScrollView(
          //   slivers: list,
          // ),
          Container(
              // margin: const EdgeInsets.only(top: Base.BASE_PADDING),
              // padding: const EdgeInsets.only(
              //   left: 20,
              //   right: 20,
              // ),
              child: settingsList),
    );
  }

  String getFlagEmoji(String countryCode) {
    // Check if the country code is exactly two letters
    if (countryCode.length != 2) {
      return ''; // Return empty string if the input is invalid
    }

    // Convert the country code to uppercase
    countryCode = countryCode.toUpperCase();

    // Calculate the regional indicator symbols
    int flagOffset = 0x1F1E6; // Unicode offset for regional indicator 'A'
    int asciiOffset = 0x41; // ASCII value for 'A'

    String firstChar = String.fromCharCode(flagOffset + countryCode.codeUnitAt(0) - asciiOffset);
    String secondChar = String.fromCharCode(flagOffset + countryCode.codeUnitAt(1) - asciiOffset);

    return firstChar + secondChar; // Combine the two regional indicator symbols
  }
  
  Future pickFiatCurrency() async {
    List<EnumObj> objs = [];
    Map<String, dynamic>? rates = await RatesUtil.fiatCurrencies();

    Map<String, Currency>? currencies = await RatesUtil.loadCurrencies();

    rates!.forEach((key, map) {
      if (map['type'] == 'fiat') {
        Currency? currency = currencies != null ? currencies[key.toUpperCase()] : null;
        objs.add(EnumObj(
            key,
             "(${map['name']} ${map['unit']})",
            widget:
                RichText(text: TextSpan(children: [
                  TextSpan(
                    text: "${key.toUpperCase()} ",
                  ),
                  TextSpan(
                    text: " ${currency!=null?getFlagEmoji(currency!.countryCode):''}"
                  ),
                  TextSpan(
                    text: " ${map['name']}",
                    style: TextStyle(color: Colors.grey[700])
                  )
                ]))
            ));
      }
    });

    objs.sort((a, b) {
      // Convert values to lowercase strings for case-insensitive comparison
      String valueA = a.value.toString().toLowerCase();
      String valueB = b.value.toString().toLowerCase();

      // Assign special priority to 'usd' and 'eur'
      if (valueA == 'usd') return -1; // 'usd' should come first
      if (valueB == 'usd') return 1;

      if (valueA == 'eur') return -1; // 'eur' should come second, after 'usd'
      if (valueB == 'eur') return 1;

      // For all other cases, use the standard string comparison
      return valueA.compareTo(valueB);
    });

    EnumObj? resultEnumObj = await EnumSelectorComponent.show(context, objs);
    if (resultEnumObj != null) {
      var a = await RatesUtil.fiatCurrency(resultEnumObj!.value);
      fiatCurrencyRate = a;
      settingProvider.currency = resultEnumObj.value;
    }
  }
}
