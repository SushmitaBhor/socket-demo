import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:socket_io/socket_io.dart';
import 'package:logger/logger.dart';
import 'package:socket_chat/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(title: 'Socket IO demo'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late socket_io.Socket socketCh;
  TextEditingController messageController = TextEditingController();

  List<Chat> chats = [];
  List<String> messages = [];
  @override
  void initState() {
    super.initState();
    createSocketConnection();
  }

  void createSocketConnection() {
    var io = Server();
    var nsp = io.of('/some');
    nsp.on('connection', (client) {
      client.on('chat', (data) {
        client.emit('fromServer', "ok 2");
      });
    });
    io.on('connection', (client) {
      client.on('chat', (data) {
        setState(() {
          messages.add(Chat.fromJson(data).content);
        });

        client.emit('fromServer', "ok");
      });
    });
    io.listen(3000);
    socketCh = socket_io.io(
        "http://localhost:3000",
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());

    socketCh.onConnect((_) => Logger().i('connected'));
    socketCh.onDisconnect((_) => Logger().e('disconnected'));
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Chat chat = Chat(content: messageController.text, time: DateTime.now());
      socketCh.emit('chat', chat);

      messageController.clear();
    }
  }

  @override
  void dispose() {
    socketCh.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
