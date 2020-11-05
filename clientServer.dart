/*
  file: getindexexample.dart
  author: James Slocum
*/
import 'dart:async';
import 'dart:io';


Socket _socket;
String IP;

void main() {
  print("what is the server ip:");
  IP = stdin.readLineSync();
  //connect to google port 80
  Socket.connect(IP, 4567).then((socket) {
    _socket = socket;
    print('Connected to chat server: ${socket.remoteAddress.address}:${socket.remotePort}');
    _socket.listen(dataHandler, onDone: doneHandler, onError: errorHandler);
  }).catchError((AsyncError e){
    print("Unable to connect: $e");
    exit(1);
  });

  stdin.listen((data) => _socket.write(new String.fromCharCodes(data).trim()));
}

void dataHandler(data){
  print(new String.fromCharCodes(data).trim());
}

void doneHandler(){
  _socket.destroy();
  exit(0);
}

void errorHandler(error){
  print(error);
}