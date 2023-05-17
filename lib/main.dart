import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MaterialApp(
    home: mainpage(),
    debugShowCheckedModeBanner: false,
  ));
}

class mainpage extends StatefulWidget {
  @override
  State<mainpage> createState() => _mainpageState();
}

class _mainpageState extends State<mainpage> {
  List someImages = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initImages();
  }

  FlutterTts flutterTts = FlutterTts();
  final player = AudioPlayer();
  int totalwins = 0;
  bool win = false;
  Color wincolor = Colors.green.shade300;
  Color losecolor = Colors.white;
  bool status = false;
  String imagepath = "";
  String spelling = "";
  List<String> toplist = [];
  List bottomlist = [];
  List<String> answerlist = [];
  Map saveindex = {};

  Future initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.webp'))
        .toList();

    setState(() {
      someImages = imagePaths;
      print("someImages======$someImages");

      int aa = Random().nextInt(someImages.length);
      print("aa=$aa");

      imagepath = someImages[aa];
      print("Imagepath ====$imagepath");

      spelling = imagepath.split("/")[1].split("\.")[0];
      print("Spelling ====$spelling");

      toplist = List.filled(spelling.length, "");
      print("toplist===$toplist");

      answerlist = spelling.split("");
      print("answerlist====$answerlist");

      String alphabets = "abcdefghijklmnopqrstuvwxyz";
      List ab = alphabets.split("");
      ab.shuffle();

      bottomlist = ab.getRange(0, 10 - toplist.length).toList();
      bottomlist.addAll(answerlist);
      bottomlist.shuffle();
      print("saveindex === $saveindex");
      print("bottomlist===$bottomlist");

      status = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: status
          ? Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      height: 500,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 50, top: 100, bottom: 100, right: 50),
                        child: Image(
                          image: AssetImage("$imagepath"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            win = false;
                            losecolor = Colors.transparent;
                            initImages();
                          });
                        },
                        child: Container(
                          child: Text(
                            "Skip",
                            style: TextStyle(fontSize: 18),
                          ),
                          height: 50,
                          width: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 10,
                      child: Container(
                        child: totalwins == 0
                            ? Text(
                                "",
                                style: TextStyle(fontSize: 18),
                              )
                            : Text(
                                "$totalwins",
                                style: TextStyle(fontSize: 18),
                              ),
                        height: 50,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: totalwins == 0
                              ? null
                              : Border.all(
                                  color: Colors.black.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  height: 50,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: answerlist.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1),
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            if (toplist[index].isNotEmpty) {
                              bottomlist[saveindex[index]] = toplist[index];
                              toplist[index] = "";
                            }
                            if (answerlist.toString().length !=
                                toplist.toString().length) {
                              losecolor = Colors.transparent;
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(4),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: win ? wincolor : losecolor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: win ? wincolor : Colors.black),
                          ),
                          child: Text(
                            "${toplist[index].toString().toUpperCase()}",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  height: 120,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: win ? bottomlist.length : bottomlist.length + 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      if (index == 10) {
                        if (win) {
                        } else {
                          return InkWell(
                            onTap: () {
                              flutterTts.speak("$spelling");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(4),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.deepPurple),
                              ),
                              child: Icon(
                                size: 28,
                                Icons.lightbulb_outline,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      }
                      if (index == 11) {
                        if (win) {
                        } else {
                          return InkWell(
                            onTap: () async {
                              for (int i = 0; i < toplist.length; i++) {
                                await Future.delayed(
                                    Duration(milliseconds: 1500));
                                flutterTts.speak("${answerlist[i]}");
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(4),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.deepPurple),
                              ),
                              child: Icon(
                                size: 28,
                                Icons.speaker_outlined,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      }
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            for (int i = 0; i < toplist.length; i++) {
                              if (toplist[i].toString().isEmpty) {
                                toplist[i] = bottomlist[index];
                                print("toplist index===${toplist[i]}");
                                print("saved index===$saveindex");
                                bottomlist[index] = "";
                                saveindex[i] = index;

                                if (listEquals(answerlist, toplist)) {
                                  player.setAsset("audio/champsound.mp3");
                                  print("Won the round");
                                  bottomlist.clear();
                                  win = true;

                                  Future.delayed(Duration(milliseconds: 500))
                                      .then((value) {
                                    player.play();
                                    return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Lottie.asset(
                                          "RawAnimation/madesimple.json",
                                          frameRate: FrameRate(60),
                                        );
                                      },
                                    );
                                  });

                                  Future.delayed(Duration(milliseconds: 3500))
                                      .then((value) {
                                    player.stop();
                                    Navigator.pop(context);
                                    win = false;
                                    losecolor = Colors.transparent;
                                    totalwins = totalwins + 1;
                                    return initImages();
                                    // return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    //   totalwins = totalwins + 1;
                                    //   return mainpage();
                                    // },
                                    // ));
                                  });
                                } else {
                                  if (answerlist.toString().length ==
                                      toplist.toString().length) {
                                    player.setAsset("audio/losesound.mp3");
                                    Future.delayed(Duration(milliseconds: 500))
                                        .then((value) {
                                      player.play();
                                    });
                                    losecolor = Colors.red.shade400;
                                  }
                                }
                              }
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(4),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            "${bottomlist[index].toString().toUpperCase()}",
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
    );
  }
}
