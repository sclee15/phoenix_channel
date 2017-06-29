import 'dart:async';
import 'package:js/js.dart';
import 'interop/js_interop.dart';
import 'interop/phoenix_interop.dart';

class ReceivePayload {
  String event;
  Map map;
  String text;
  ReceivePayload(this.event, {this.map, this.text});
}

class Push  extends Intf<PushImpl>{
  Push receive( String eventName,  callback(map) ){
    var ret = jsObject.receive(eventName, allowInterop( (first, [second]){
      var conv = dartify(first);
      callback(conv);
    }));
    return new Push.fromJsObject(ret);
  }

  StreamController<Map> _receiveController;
  
  Stream<Map> receiveViaStream( String eventName ){
    jsObject.receive(eventName, allowInterop( (first, [second]){
      var conv = dartify(first);
      if (_receiveController.isClosed == false){
        _receiveController.add(conv);
      }
    }));
    _receiveController = new StreamController<Map>.broadcast(sync: true);
    return _receiveController.stream;
  }

  Push.fromJsObject(PushImpl jsObject) : super.fromJsObject(jsObject);
}