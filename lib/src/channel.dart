import 'dart:async';
import 'package:js/js.dart';
import 'interop/js_interop.dart';
import 'interop/phoenix_interop.dart';
import 'push.dart';

class Channel extends Intf<ChannelImpl>{
  Push _joinPush;
  Push join([int timeout]){
    if (_joinPush != null){
      return _joinPush;
    }

    PushImpl pushImpl;
    if (timeout == null){
      pushImpl = jsObject.join();
    }else{
      pushImpl = jsObject.join( timeout );
    }
    _joinPush = new Push.fromJsObject(pushImpl);
    return _joinPush;
  }

  Push leave([int timeout]){
    PushImpl pushImpl;
    if (timeout == null){
      pushImpl = jsObject.leave();
    }else{
      pushImpl = jsObject.leave( timeout );
    }
    return new Push.fromJsObject(pushImpl);
  }

  Push push(String event, Map payload, [int timeout]){
    PushImpl pushImpl;
    if (timeout == null){
      pushImpl = jsObject.push(event, jsify(payload));
    }else{
      pushImpl = jsObject.push(event, jsify(payload), timeout);
    }
    return new Push.fromJsObject(pushImpl);
  }

  int cntlCnt = 0;
  Map<String, OnChannel > onMap = {};
  Map<String, Map<int, StreamController<Map>>> onStreams = {};
  Stream<Map> on(String event){
    if (onMap[event] == null){
      onMap[event] = new OnChannel(jsObject, event);
      onMap[event].stream.listen( (map){
        onStreams[event].forEach( (k, v){
          try{
            if (v.isClosed == false)
              v.add(map);
          }catch(e){ }
        } );
      } );
    }

    int nowId = cntlCnt++;
    var handler = new OnChannel(null, event, key: nowId, registers: onStreams, rootOnChannels: onMap);
    if (onStreams[event] == null)
      onStreams[event] = {};    
    onStreams[event][nowId] = handler.controller;
    return handler.controller.stream;
  }

  Channel.fromJsObject(ChannelImpl jsObject) : super.fromJsObject(jsObject);
}

class OnChannel{
  ChannelImpl jsObject;  
  StreamController<Map> controller;
  Stream<Map> stream;
  String event;
  int key;
  Map<String, OnChannel > rootOnChannels;
  Map<String, Map<int, StreamController<Map>>> registers;
  
  OnChannel(this.jsObject, this.event, {this.key, this.registers, this.rootOnChannels}){
    var nextWrapper = allowInterop( (a, [b, c]){
      var darto = dartify(a);
      controller.add( darto );
    });

    void startListen(){
      print("start listening ${event}");
      if (jsObject != null)
        jsObject.on(event, nextWrapper);
    }

    void stopListen(){
      if (jsObject != null){
        print("stop parent listening ${event}");
        jsObject.off(event);
      }        
      else{
        print("stop listening ${event}");
        registers[event][key].close();
        registers[event].remove(key);
        
        if (registers[event].keys.length == 0){
          if (rootOnChannels[event] != null){
            rootOnChannels[event].controller.close();
            rootOnChannels.remove(event);
          }
          registers.remove(event);
        }
      }
    }

    controller = new StreamController<Map>.broadcast(onListen: startListen, onCancel: stopListen, sync: true);
    stream = controller.stream;
  }
}