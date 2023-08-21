import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/src/web/file_service.dart';
import 'package:http/http.dart' as http;

import '../../consts/base64.dart';

class RetryHttpFileService extends FileService {
  final http.Client _httpClient;

  RetryHttpFileService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    url = url.trim();
    // log("begin to load image from ${url}");
    if (BASE64.check(url)) {
      return Baes64FileResponse(BASE64.toData(url));
    }

    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    final httpResponse = await _httpClient.send(req);

    return HttpGetResponse(httpResponse);
  }
}

class Baes64FileResponse implements FileServiceResponse {
  Uint8List data;

  Baes64FileResponse(this.data);

  final DateTime _receivedTime = DateTime.now();

  @override
  int get statusCode => HttpStatus.ok;

  String? _header(String name) {
    return null;
  }

  @override
  Stream<List<int>> get content {
    return Stream.value(data.toList());
  }

  @override
  int? get contentLength => data.length;

  @override
  DateTime get validTill {
    var ageDuration = const Duration(days: 7);
    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag => _header(HttpHeaders.etagHeader);

  @override
  String get fileExtension {
    // TODO this is not the real extension
    return "jpeg";
  }
}
