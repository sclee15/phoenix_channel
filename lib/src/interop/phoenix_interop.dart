@JS()
library phoenix.interop;
import 'package:js/js.dart';

abstract class Intf<T> {
  T jsObject;
  Intf.fromJsObject(this.jsObject);
  Intf(){}
}


@JS("Phoenix.Socket")
class SocketImpl {
  external SocketImpl(String endPoint, [ dynamic opts ]);
  external void connect([dynamic params]);
  external ChannelImpl channel(String topic, dynamic chanparam);
}

@JS("Phoenix.Channel")
class ChannelImpl {
  external PushImpl join([int timeout]);
  external PushImpl leave([int timeout]);
  external on(String event, Function callback);
  external off(String event);
  external PushImpl push(String event, payload, [int timeout]);
}

@JS("")
@anonymous
class PushImpl{
  external PushImpl receive(String status,  Function callback );
}

@JS()
@anonymous
class SocketOptions {
  external bool get params;
  
  external factory SocketOptions({bool responsive});
}

