import 'dart:io';

import 'package:isar/isar.dart';

import '../models/db/db_contact_list.dart';
import '../models/db/db_event.dart';
import '../models/db/db_metadata.dart';
import '../models/db/db_nip05.dart';
import '../models/db/db_relay_set.dart';
import '../models/db/db_user_relay_list.dart';

class IsarDbDs {
  late Isar isar;

  IsarDbDs();

  Future<void> init({String? directory, bool debug = false}) async {
    // await Isar.initialize("./libisar_android_armv7.so");//initializeIsarCore(download: true);

    // final dir = await getApplicationDocumentsDirectory();
    // final dir = Directory.systemTemp.createTempSync()
    if (directory == Isar.sqliteInMemory) {
      await Isar.initialize();
    }
    isar = Isar.open(
      name: "db_ndk_${debug ? "debug" : "release"}",
      inspector: debug,
      maxSizeMiB: 1024,
      compactOnLaunch: const CompactCondition(
          minRatio: 2.0,
          minBytes: 100 * 1024 * 1024,
          minFileSize: 256 * 1024 * 1024),
      directory: directory ?? Directory.systemTemp.path,
      engine: directory == Isar.sqliteInMemory
          ? IsarEngine.sqlite
          : IsarEngine.isar,
      schemas: [
        DbEventSchema,
        DbUserRelayListSchema,
        DbRelaySetSchema,
        DbContactListSchema,
        DbMetadataSchema,
        DbNip05Schema
      ],
    );
    // isar.write((isar) {
    //   isar.clear();
    // });
  }
}
