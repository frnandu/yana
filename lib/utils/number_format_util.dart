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
}
