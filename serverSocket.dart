/**
    file: serverexample.dart
    author: James Slocum

    Simple server that will
    1) accept a new connection
    2) say hello
    3) close the connection
 */

import 'dart:io';

class ChatClient{
  Socket _socket;
  String ipv4;
  int port;
  String name;

  ChatClient(Socket socket){
    _socket = socket;
    ipv4 = socket.remoteAddress.address;
    port = socket.remotePort;
    name = ipv4;

    _socket.listen(messageHandler, onDone: doneHandler, onError: errorHandler);
  }

  void messageHandler(data){
    String message = new String.fromCharCodes(data).trim();
    if (message.startsWith("/rename ")){
      name = message.substring(7,message.length);
    }
    else{distributeMessage(this, message);}
  }

  void doneHandler(){
    print("$ipv4 has disconnected");
    distributeMessage(this, "has left the chat");
    removeClient(this);
  }

  void errorHandler(error){
    print("$ipv4 error: $error");
    removeClient(this);
  }

  void write(String message){
    _socket.write(message);
  }
}


List<ChatClient> clients = [];

void removeClient(ChatClient client){
  client._socket.close();
  clients.remove(client);
}

void distributeMessage(ChatClient client, String message){
  for (ChatClient c in clients){
    if (c != client){
      c.write("${client.name}: $message");
    }
  }
}

void main() {
  ServerSocket.bind(InternetAddress.ANY_IP_V4, 4567).then(
          (ServerSocket server) {
        print("[LISTENING] Listening for connections");
        server.listen(handleClient);
      }
  );
}

void handleClient(Socket client){
  print("${client.remoteAddress.address}: has connected.");
  clients.add(ChatClient(client));
  client.write("Welcome to chat,\nOnline users: ${clients.length - 1}");
}