import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class SSLPinningClient extends IOClient {
  SSLPinningClient(HttpClient client) : super(client);

  static Future<http.Client> getClient() async {
    final sslCert = await rootBundle.load('assets/themoviedb.pem');
    final securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
    
    final httpClient = HttpClient(context: securityContext);
    httpClient.badCertificateCallback = (cert, host, port) => false;
    return SSLPinningClient(httpClient);
  }
}
