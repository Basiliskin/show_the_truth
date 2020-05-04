import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:knesset_odata/util/common.dart';
import 'package:tweetnacl/tweetnacl.dart';
// import 'package:knesset_odata/util/nacl.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');
final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

class Request {
  final keyPair = Box.keyPair();

  Map<String, String> _headers = {'Content-Type': 'application/json'};
  String baseUrl =
      isProduction ? "http://127.0.0.1:2222" : "http://10.0.2.2:2222";
  http.Client _client;
  final String publicKey;
  Request([this.publicKey]) {
    this._client = this._client ?? http.Client();
  }

  Map<String, dynamic> deccryptBody(res) {
    dynamic response = json.decode(res);
    Map<String, dynamic> data = new Map<String, dynamic>.from(response["data"]);
    if (data.containsKey("encrypted")) {
      dynamic d = decompress(data["encrypted"]);
      return _decrypt(json.decode(d));
    } else if (data.containsKey("plain")) {
      dynamic d = decompress(data["plain"]);
      return json.decode(d);
    }
    return response;
  }

  Uint8List _publicKey(String key) {
    final publicKeyValues = key.split(",");
    final keys = publicKeyValues.map(int.parse).toList();
    return Uint8List.fromList(keys);
  }

  _decrypt(Map<String, dynamic> obj) {
    final ciphertext = base64.decode(obj["ciphertext"]);
    final ephemPubKey = _publicKey(obj["ephemPubKey"]);
    final nonce = base64.decode(obj["nonce"]);

    final bobBox = Box(ephemPubKey, keyPair.secretKey);
    final message = bobBox.open_nonce(ciphertext, nonce);
    final data = utf8.decode(message);
    final response = json.decode(data);
    print("_decrypt: $response");
    return response["payload"];
  }

  _encrypt(Map<String, dynamic> obj) {
    String msgParams = json.encode(obj);
    final pubKeyUInt8Array = _publicKey(publicKey);
    final bobBox = Box(pubKeyUInt8Array, keyPair.secretKey);
    final nonce = TweetNaclFast.randombytes(24);
    final msgParamsUInt8Array = Uint8List.fromList(utf8.encode(msgParams));
    final encryptedMessage = bobBox.box_nonce(msgParamsUInt8Array, nonce);
    return {
      "publicKey": publicKey,
      "ephemPubKey": base64.encode(keyPair.publicKey),
      "ciphertext": base64.encode(encryptedMessage),
      "nonce": base64.encode(nonce),
      "version": "1.0.2"
    };
  }

  Map<String, dynamic> encryptBody(Map<String, dynamic> obj, bool encrypted) {
    if (publicKey == null || encrypted == false) {
      if (encrypted)
        obj["payload"]["publicKey"] = "${base64.encode(keyPair.publicKey)}";
      return {
        "header": json.encode(obj["header"]),
        "payload": json.encode(obj["payload"])
      };
    } else {
      final data = _encrypt(obj);
      return {
        "header": json.encode(obj["header"]),
        "payload": json.encode(data)
      };
    }
  }

  Future<Map<String, dynamic>> request(url, body,
      [bool encrypted = false]) async {
    var serverUrl = Uri.parse("$baseUrl$url");
    try {
      final ebode = encryptBody(body, encrypted);
      var res = await _client.post(serverUrl,
          body: json.encode(ebode), headers: _headers);
      return deccryptBody(res.body);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Map<String, dynamic>> secureRequest(url, body) async {
    return request(url, body, true);
  }
}
