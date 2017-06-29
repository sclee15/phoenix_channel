library phoenix.socket;

import 'interop/phoenix_interop.dart';
import 'interop/js_interop.dart';
import 'channel.dart';

class Socket extends Intf<SocketImpl>{
  Socket(String endPoint, [ Map opts ]){
    if (opts != null){
      jsObject = new SocketImpl(endPoint, jsify(opts));
    }else{
      jsObject = new SocketImpl(endPoint, null);
    } 
  }

  Map<String, Channel> topics = {};

  void connect([param]) => jsObject.connect(jsify(param));
  Channel channel(String topic, Map param){
    if (topics[topic] == null){
      var jso = jsObject.channel(topic, jsify(param));
      var a = new Channel.fromJsObject(jso);
      topics[topic] = a;
      return a;
    }else{
      return topics[topic];
    }
  }
}