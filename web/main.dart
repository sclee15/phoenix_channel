// Copyright (c) 2017, S.-C. Lee. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:phoenix/phoenix.dart';

Future<Null> main() async {
  querySelector('#output').text = 'Your Dart app is running.';

  var socket = new Socket("//localhost:4000/socket", {
    "params": {
      "user": "token"
    }
  });

  socket.connect();
  print("connected");
  
  var channel = socket.channel("chat:chatchannel", {});
  var channel2 = socket.channel("chat:chatchannel", {});

  channel.join()
    .receive("ok", (map){
      print("ok");
      print(map);
      map["code"] = "ok";
    })
    .receive("timeout", (map){
      print("timeout");
      print(map);
      map["code"] = "timeout";
    })
    .receive("error", (map){
      print("error");
      print(map);
      map["code"] = "error";
    });

  var ping1 = channel.on("pong").listen((map){
    print("ping1: " + map["count"].toString());
  });

  var ping2 = channel.on("pong").listen((map){
    print("ping2: " + map["count"].toString());
  });
  
  // querySelector('#output').onClick.listen( (event){
  //   print("sent");
  //   channel.push("pong", jsify({ "Dart": "Dart Inter-op" }));
  // });

  querySelector('#stop1').onClick.listen( (event){
    print("stopping1");
    ping1.cancel();
  });

  querySelector('#stop2').onClick.listen( (event){
    print("stopping2");
    ping2.cancel();
  });

  //reopen1
  StreamController<int> streamC = new StreamController<int>.broadcast();

  querySelector('#reopen1').onClick.listen( (event){
    channel2.join().receive("ok", (map){
      print("c2 ok");
    })
    .receive("timeout", (map){
      print("c2 timeout");
    })
    .receive("error", (map){
      print("c2 error");
    });
    // var ping3 = channel.on("pong").listen((map){
    //   print("ping3: " + map["count"].toString());
    // });
  });
  
  streamC.add(1);
  streamC.add(2);
  streamC.add(3);
  streamC.add(4);
  streamC.add(5);

  print("out of end");
}
  