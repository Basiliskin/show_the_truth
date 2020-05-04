import 'dart:async';
import 'dart:convert';

import 'dart:io';

class ErrorMessage extends Error {
  final Object message;
  ErrorMessage([this.message]);
  String toString() => "ERR: $message";
}

Future storeDispatch(store, action) {
  Completer completer = new Completer();
  store.dispatch(action(completer));
  return completer.future;
}

final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

prettyPrint(Map<String, dynamic> obj) {
  String res = encoder.convert(obj);
  print(res);
}

decompress(String text) {
  List<int> gzipBytes = text.codeUnits;
  List<int> stringBytes = gzip.decode(gzipBytes);
  return utf8.decode(stringBytes);
}
