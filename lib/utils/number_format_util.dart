import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberFormatUtil {
  static String format(int num) {
    String numStr = num.toString();
    if (num > 1000000) {
      numStr = (num / 1000000).toStringAsFixed(1) + "m";
    } else if (num > 1000) {
      numStr = (num / 1000).toStringAsFixed(1) + "k";
    }

    return numStr;
  }

  static RichText formatBitcoinAmountOld(double amount) {
    // Convert the double amount to a string with a specified number of decimal places
    String formattedAmount = amount.toStringAsFixed(8); // 8 decimal places for BTC

    // Find the index of the first non-zero digit
    int firstNonZeroIndex = formattedAmount.indexOf(RegExp(r'[^0\.]'));

    // Create a list of TextSpans for different formatting
    List<InlineSpan> spans = [];

    // Add grey TextSpan for zeros left of the first non-zero digit
    spans.add(
      TextSpan(
        text: formattedAmount.substring(0, firstNonZeroIndex),
        style: TextStyle(color: Colors.grey),
      ),
    );

    // Add white TextSpan for digits right of the first non-zero digit
    spans.add(
      TextSpan(
        text: formattedAmount.substring(firstNonZeroIndex),
        style: TextStyle(color: Colors.white),
      ),
    );

    // Create a RichText widget to display the formatted amount
    return RichText(
      text: TextSpan(children: spans),
    ); // Convert RichText to plain text for display
  }

  static RichText formatBitcoinAmount(double amount, TextStyle empty, TextStyle filled) {
    // Convert the amount to a string with desired formatting
    String formattedAmount = amount.toStringAsFixed(8); // 8 decimal places

    // Find the index of the first non-zero digit
    int firstNonZeroIndex = formattedAmount.indexOf(RegExp(r'[1-9]'));

    // Split the string into parts before and after the first non-zero digit
    String beforeDecimal = formattedAmount.substring(0, firstNonZeroIndex);
    String afterDecimal = formattedAmount.substring(firstNonZeroIndex);

    // Add spaces every 3 characters before the decimal point, excluding leading zeros
    beforeDecimal = beforeDecimal.replaceAllMapped(
        RegExp(r'(\d)(?=(?:\d{3})+(?!\d))'), (match) => '${match[1]} ');

    afterDecimal = afterDecimal.replaceAllMapped(
        RegExp(r'(\d)(?=(?:\d{3})+(?!\d))'), (match) => '${match[1]} ');

    // If there are no digits after the decimal point, add a space
    if (afterDecimal.length==3) {
      afterDecimal = ' $afterDecimal';
    }

    // Create a list of TextSpans with different colors
    List<TextSpan> textSpans = [
      TextSpan(
        text: beforeDecimal,
        style: empty,
      ),
      TextSpan(
        text: afterDecimal,
        style: filled,
      ),
    ];
    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
  static NumberFormat f1 = NumberFormat('#.## 000 000');

  static String formatSats1(int num) {
    String numStr = num.toString();
    NumberFormat f1 = NumberFormat('0.00');
    return f1.format(num/100000000);
    // return (num / 100000000).toStringAsFixed(8);
  }

  static String formatSats2(int num) {
    String numStr = num.toString();
    NumberFormat f1 = NumberFormat('0.00');
    return f1.format((num%1000000));
    // return (num / 100000000).toStringAsFixed(8);
  }

  static String formatSatsFilled(int num) {
    String numStr = num.toString();


    if (num > 1000000) {
      numStr = (num / 1000000).toStringAsFixed(1) + "m";
    } else if (num > 1000) {
      numStr = (num / 1000).toStringAsFixed(1) + "k";
    }

    return numStr;
  }

}
