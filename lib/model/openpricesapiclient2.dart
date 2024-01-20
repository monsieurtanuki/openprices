import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openprices/model/http_helper.dart' as http_helper2;
import 'package:openprices/model/maybe_error.dart';
import 'package:openprices/model/proof.dart';
import 'package:openprices/model/proof_type.dart';

/// Client calls of the Open Prices API.
class OpenPricesAPIClient2 {
  OpenPricesAPIClient2._();

  /// Subdomain of the Elastic Search API.
  static const String _subdomain = 'prices';

  /// Host of the Elastic Search API.
  static String _getHost(final UriProductHelper uriHelper) =>
      uriHelper.getHost(_subdomain);

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// cf. https://prices.openfoodfacts.org/api/docs#/default/get_price_api_v1_prices_get
  static Future<GetPricesResults> getPrices({
    // TODO(monsieurtanuki): add all parameters
    final int? pageSize,
    final int? pageNumber,
    final String? productCode,
    final int? locationId,
    final String? owner,
    final int? locationOSMId,
    final LocationOSMType? locationOSMType,
    final Currency? currency,
    final DateTime? date,
    final DateTime? dateGt,
    final DateTime? dateGte,
    final DateTime? dateLt,
    final DateTime? dateLte,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices',
      queryParameters: <String, String>{
        if (pageNumber != null) 'page': pageNumber.toString(),
        if (pageSize != null) 'size': pageSize.toString(),
        if (productCode != null) 'product_code': productCode,
        if (locationId != null) 'location_id': locationId.toString(),
        if (owner != null) 'owner': owner,
        if (locationOSMId != null) 'location_osm_id': locationOSMId.toString(),
        if (locationOSMType != null)
          'location_osm_type': locationOSMType.offTag,
        if (currency != null) 'currency': currency.name,
        if (date != null) 'date': _formatDate(date),
        if (dateGt != null) 'date__gt': _formatDate(dateGt),
        if (dateGte != null) 'date__gte': _formatDate(dateGte),
        if (dateLt != null) 'date__lt': _formatDate(dateLt),
        if (dateLte != null) 'date__lte': _formatDate(dateLte),
      },
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      uriHelper: uriHelper,
    );
    dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
    if (response.statusCode == 200) {
      return GetPricesResults.result(GetPricesResult.fromJson(decodedResponse));
    }
    return GetPricesResults.error(ValidationErrors.fromJson(decodedResponse));
  }

  static Future<String> getAuthenticationToken({
    required final String username,
    required final String password,
    final bool setCookie = false,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/auth${setCookie ? '?set_cookie=1' : ''}',
      forcedHost: _getHost(uriHelper),
    );
    final Response response = await post(
      uri,
      body: <String, String>{
        'username': username,
        'password': password,
      },
    );
    dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
    if (response.statusCode == 200) {
      return decodedResponse['access_token'];
    }
    throw Exception(
      'Could not retrieve token: $decodedResponse (${response.statusCode})',
    );
  }

  static String _formatDate(final DateTime date) => _dateFormat.format(date);

  static Future<MaybeError<Price>> addPrice({
    required final String productCode,
    // TODO: 2 product name
    // TODO: 2 category tag
    // TODO: 2 labels tags
    // TODO: 2 origins tags
    required final double price,
    // TODO: 2 price without discount
    // TODO: 2 price per
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final DateTime date,
    final int? proofId,
    required final String bearerToken,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices',
      forcedHost: _getHost(uriHelper),
    );
    final String parameters = '{'
        '"product_code": "$productCode",'
        '"price": $price,'
        '"currency": "${currency.name}",'
        '"location_osm_id": $locationOSMId,'
        '"location_osm_type": "${locationOSMType.offTag}",'
        '${proofId == null ? '' : '"proof_id": $proofId,'}'
        '"date": "${_dateFormat.format(date)}"'
        '}';
    final Response response = await post(
      uri,
      headers: <String, String>{
        'Authorization': 'bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: parameters,
    );
    print('bbbooody: ${response.body}');
    final Map<String, dynamic> json = HttpHelper().jsonDecodeUtf8(response);
    if (response.statusCode == 201) {
      return MaybeError<Price>.value(Price.fromJson(json));
    }
    return MaybeError<Price>.error(response.body);
    /*
(201)
{"product_code":"3560071492755","product_name":null,"category_tag":null,"labels_tags":null,"origins_tags":null,"price":3.99,"price_without_discount":null,"price_per":null,"currency":"EUR","location_osm_id":4966187139,"location_osm_type":"NODE","date":"2024-01-18","proof_id":1663,"product_id":null,"location_id":null,"owner":"monsieurtanuki","created":"2024-01-20T18:09:57.887607Z"}

(401)
{detail: Not authenticated}
     */
  }

  static Future<MaybeError<Proof>> uploadProof({
    required final Uri imageUri,
    required final ProofType proofType,
    required final bool isPublic,
    required final String bearerToken,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/proofs/upload',
      forcedHost: _getHost(uriHelper),
    );
    final StreamedResponse response =
        await http_helper2.HttpHelper().doMultipartRequest(
      uri,
      <String, String>{
        'type': proofType.offTag,
        'is_public': isPublic ? 'true' : 'false',
      },
      files: <String, Uri>{
        'file': imageUri,
      },
      bearerToken: bearerToken,
      uriHelper: uriHelper,
    );
    final String responseBody =
        await http_helper2.HttpHelper().extractResponseAsString(
      response,
    );
    // 201: "created"
    if (response.statusCode == 201) {
      final Map<String, dynamic> json =
          http_helper2.HttpHelper().jsonDecode(responseBody);
      return MaybeError<Proof>.value(Proof.fromJson(json));
    }
    return MaybeError<Proof>.error(responseBody);
/*
401
{"detail":"Not authenticated"}

201
{
  "id":1576,
  "file_path":"0002/Vl3AaqMmr5.bin",
  "mimetype":"application/octet-stream",
  "type":"RECEIPT",
  "owner":"monsieurtanuki",
  "created":"2024-01-20T09:38:26.510286Z",
  "is_public":true
}
 */
  }

/*
    {
  "product_code": "16584958",
  "product_name": "PATE NOCCIOLATA BIO 700G",
  "category_tag": "en:tomatoes",
  "labels_tags": "en:organic",
  "origins_tags": "en:california",
  "price": 1.99,
  "price_without_discount": 2.99,
  "price_per": "KILOGRAM",
  "currency": "EUR",
  "location_osm_id": 1234567890,
  "location_osm_type": "NODE",
  "date": "2024-01-14",
  "proof_id": 15
}
     */

/*
  NODE 5324689769
   */
}
