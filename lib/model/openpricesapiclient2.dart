import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

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

  static Future<String?> getAuthenticationToken({
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
    print('resp: $decodedResponse (${response.statusCode})');
    if (response.statusCode == 200) {
      // {access_token: monsieurtanuki__U7a60e92f-zzzz-4fe8-806e-dfbd184972c5, token_type: bearer} (200)
      return null;
    }
    // {detail: Invalid authentication credentials} (401)
    return null;
  }

  static String _formatDate(final DateTime date) => _dateFormat.format(date);

  static Future<void> addPrice({
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
    required final String productCode,
    required final double price,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final DateTime date,
    final UriProductHelper uriHelper = uriHelperFoodProd,
  }) async {
    final Uri uri = uriHelper.getUri(
      path: '/api/v1/prices',
      forcedHost: _getHost(uriHelper),
    );
    const String bearerToken =
        'monsieurtanuki__U96e5bc94-zzzz-4f5e-ab29-c6b8e7d72ed9'; // TODO
    dynamic toto = '{'
        '"product_code": "$productCode",'
        '"price": $price,'
        '"currency": "${currency.name}",'
        '"location_osm_id": $locationOSMId,'
        '"location_osm_type": "${locationOSMType.offTag}",'
        '"date": "${_dateFormat.format(date)}"'
        '}';
    //"product_name": "PATE NOCCIOLATA BIO 700G",
    //"category_tag": "en:tomatoes",
    //"labels_tags": "en:organic",
    //"origins_tags": "en:california",
    //"price_without_discount": 2.99,
    //"price_per": "KILOGRAM",
    //"proof_id": 15
    print('toto: $toto');
    final Response response = await post(
      uri,
      headers: <String, String>{
        'Authorization': 'bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: toto,
    );
    dynamic decodedResponse = HttpHelper().jsonDecodeUtf8(response);
    print('add price: $decodedResponse (${response.statusCode})');
    /*
    {product_code: 5010477348678, product_name: null, category_tag: null, labels_tags: null, origins_tags: null, price: 3.99, price_without_discount: null, price_per: null, currency: EUR, location_osm_id: 5324689769, location_osm_type: NODE, date: 2024-01-13, proof_id: null, product_id: null, location_id: null, owner: monsieurtanuki, created: 2024-01-14T15:40:45.120187Z} (201)

     */
    /*
    if (response.statusCode == 200) {
      return GetPricesResults.result(GetPricesResult.fromJson(decodedResponse));
    }
    return GetPricesResults.error(ValidationErrors.fromJson(decodedResponse));

     */
    // {detail: Not authenticated} (401)
  }

/*
  NODE 5324689769
   */
}
