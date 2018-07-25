@JS()
library phoenix.js_interop;

import 'package:js/js.dart';
import 'dart:convert';

@JS("alert")
external dynamic alert2(String Message);

@JS("console.log")
external dynamic consolelog(obj);

@JS("JSON.stringify")
external String stringify(obj);

@JS("JSON.parse")
external dynamic parse(s);

bool _isBasicType(value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

dynamic jsify(Object dartObject) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  Object jsonO;
  try {
    jsonO = json.encode(dartObject, toEncodable: _noCustomEncodable);
  } on JsonUnsupportedObjectError {
    throw new ArgumentError("Only basic JS types are supported");
  }
  return parse(jsonO);
}

_noCustomEncodable(value) =>
    throw new UnsupportedError("Object with toJson shouldn't work either");

dynamic dartify(Object jsObject) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  var jsonO = stringify(jsObject);
  return json.decode(jsonO);
}
