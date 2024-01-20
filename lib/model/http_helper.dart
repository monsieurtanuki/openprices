import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart';

/// General functions for sending http requests (post, get, multipart, ...)
class HttpHelper {
  /// Gets the instance
  static HttpHelper get instance => _instance ??= HttpHelper.internal();
  static HttpHelper? _instance;

  @visibleForTesting
  static set instance(HttpHelper value) => _instance = value;

  factory HttpHelper() => instance;

  @protected

  /// A protected constructor to allow subclasses to create themselves.
  HttpHelper.internal();

  static const String FROM = 'anonymous';

  /// Send a multipart post request to the specified uri.
  /// The data / body of the request has to be provided as map. (key, value)
  /// The files to send have to be provided as map containing the source file uri.
  /// As result a json object of the "type" Status is expected.
  Future<http.StreamedResponse> doMultipartRequest(
    Uri uri,
    Map<String, String> body, {
    Map<String, Uri>? files,
    required final UriHelper uriHelper,
    required final String bearerToken,
  }) async {
    var request = http.MultipartRequest('POST', uri);

    /*
    request.headers.addAll(
      _buildHeaders(
        user: user,
        uriHelper: uriHelper,
        addCredentialsToHeader: false,
      ) as Map<String, String>,
    );

     */

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'bearer $bearerToken',
    });

    request.fields.addAll(body);

    // add all file entries to the request
    if (files != null) {
      for (MapEntry<String, Uri> entry in files.entries) {
        List<int> fileBytes =
            await UriReader.instance!.readAsBytes(entry.value);
        var multipartFile = http.MultipartFile.fromBytes(entry.key, fileBytes,
            filename: basename(entry.value.toString()));
        request.files.add(multipartFile);
      }
    }

    // get the response status
    return request.send();
  }

  Future<String> extractResponseAsString(http.StreamedResponse response) async {
    final Completer<String> completer = Completer<String>();
    final StringBuffer contents = StringBuffer();
    response.stream.transform(utf8.decoder).listen((data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  /// "Normal" json.decode, with an additional "html" exception.
  ///
  /// Typically, when the OFF server is not happy, it returns an html page.
  /// With this method we display the html page title instead of just a
  /// "it's not a json" exception.
  dynamic jsonDecode(final String string) {
    try {
      return json.decode(string);
    } catch (e) {
      if (string.startsWith('<html>')) {
        throw Exception('JSON expected, html found: ${string.split('\n')[1]}');
      }
      if (string.startsWith('<h1>Software error:</h1>')) {
        throw Exception(
            'JSON expected, software error found: ${string.split('\n')[1]}');
      }
      if (string.startsWith('<!DOCTYPE html>')) {
        const String titleOpen = '<title>';
        const String titleClose = '</title>';
        int pos1 = string.indexOf(titleOpen);
        if (pos1 >= 0) {
          pos1 += titleOpen.length;
          final int pos2 = string.indexOf(titleClose);
          if (pos2 >= 0 && pos1 < pos2) {
            throw Exception(
                'JSON expected, server error found: ${string.substring(pos1, pos2)}');
          }
        }
      }
      rethrow;
    }
  }

  /// json.decode, with utf8 conversion and additional "html" exception.
  dynamic jsonDecodeUtf8(final http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));
}
