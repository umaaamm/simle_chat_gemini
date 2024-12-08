import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:simple_chat_ai/model_text.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const apiKey = "";
  final ScrollController _controller = ScrollController();
  TextEditingController controller = TextEditingController();

  List<Content> _messages = [];
  bool isLoading = false;

  void _scrollDown() {
    // _controller.jumpTo(_controller.position.maxScrollExtent);
    _controller.animateTo(_controller.position.maxScrollExtent + 200,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void sendMessage() {
    final gemini = Gemini.instance;
    setState(() {
      isLoading = true;
    });

    gemini
        .chat(_messages)
        .then((value) => {
              setState(() {
                _messages.add(Content(
                  parts: [
                    Part.text(value?.output ?? 'Tidak ada respon'),
                  ],
                  role: 'model',
                ));
                isLoading = false;
              }),
              _scrollDown()
            })
        .catchError((e) => {
              setState(() {
                _messages.add(Content(
                  parts: [
                    Part.text('Terjadi kesalahan saat mengirim pesan'),
                  ],
                  role: 'model',
                ));
                isLoading = true;
              })
            });
  }

  @override
  void initState() {
    super.initState();

    Gemini.init(apiKey: apiKey);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              isLoading
                  ? Container(
                      margin: const EdgeInsets.all(12.0),
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Container(),
            ],
            backgroundColor: Color(0xFFF69170),
            title: const Text("AI Chat",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      itemCount: _messages.length,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            color: (_messages[index].role == 'user' &&
                                    _messages!.length > 0
                                ? Color(0xFFF69170)
                                : Colors.white),
                          ),
                          margin: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 10, top: 10),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment:
                                _messages[index].role == 'model' &&
                                        _messages!.length > 0
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _messages[index].role == 'model' &&
                                      _messages!.length > 0
                                  ? const Icon(Icons.chat_outlined,
                                      color: Color(0xFFF69170))
                                  : SizedBox(),
                              SizedBox(width: 12),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  '${_messages[index].toJson()['parts'][0]['text']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: _messages[index].role == 'model' &&
                                              _messages!.length > 0
                                          ? Colors.black
                                          : Colors.white),
                                  softWrap: true,
                                  textAlign: _messages[index].role == 'model' &&
                                          _messages!.length > 0
                                      ? TextAlign.left
                                      : TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 12),
                              _messages[index].role == 'user' &&
                                      _messages!.length > 0
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        );
                      })),
              Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Expanded(
                      child: TextFormField(
                        autocorrect: false,
                        autofocus: true,
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Apa yang ingin anda tanyakan?",
                          labelStyle:
                              TextStyle(fontSize: 16, color: Colors.black),
                          fillColor: Colors.black,
                          focusColor: Colors.black,
                          hoverColor: Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0))),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 32.0,
                      onPressed: () {
                        _scrollDown();
                        sendMessage();
                        setState(() {
                          _messages.add(Content(
                            parts: [
                              Part.text(controller.text),
                            ],
                            role: 'user',
                          ));
                          controller.clear();
                        });
                      },
                    )
                  ])),
            ],
          ),
        ));
  }
}
