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

    String beforeFirstZero="";
    String afterFirstZero="";

    int i=0;
    bool afterDecimal = false;
    bool afterFirstNonZero = false;
    int decimalPosition = 0;
    while (i < formattedAmount.length) {
      if (formattedAmount[i] == '.') {
        afterDecimal = true;
        if (afterFirstNonZero) {
          afterFirstZero += ".";
        } else {
          beforeFirstZero += ".";
        }
        i++;
        continue;
      }
      if (formattedAmount[i]!='0') {
        afterFirstNonZero = true;
      }
      String additionalSpace = "";
      if (decimalPosition == 2 || decimalPosition == 5) {
        additionalSpace = " ";
      }

      if (afterFirstNonZero) {
        afterFirstZero += additionalSpace + formattedAmount[i];
      } else {
        beforeFirstZero += additionalSpace + formattedAmount[i];
      }
      i++;
      if (afterDecimal) {
        decimalPosition++;
      }
    }

    // Create a list of TextSpans with different colors
    List<TextSpan> textSpans = [

      TextSpan(
        text: beforeFirstZero,
        style: empty,
      ),
      TextSpan(
        text: afterFirstZero,
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
