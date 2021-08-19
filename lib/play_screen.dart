import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poketunes/audio.dart';
import 'package:poketunes/poke_box.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'dart:io' show Platform;

class PlayScreen extends StatefulWidget {
  static const String id = 'play_screen';

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var startList = new List<int>.generate(151, (i) => i + 1);
  List gameList = [];
  int highScore = 0;
  int score = 0;
  String pokemon = '';
  String initialText = stringList[0];
  bool showTextField = false;

  T getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  getElementInit() {
    var list;
    list = startList;
    var element = getRandomElement(list);
    print(element);
    gameList.add(element);
  }

  getElement() {
    var list;
    print(gameList);
    if (gameList.length > 0 && gameList.length < 151) {
      for (int i = 0; i < gameList.length; i++) {
        startList.remove(gameList[i]);
        list = startList;
      }
      var element = getRandomElement(list);
      var elementString = getRandomElement(stringList);
      print(element);
      setState(() {
        gameList.add(element);
        initialText = elementString;
      });
      print(gameList);
      playSound(element);
    } else if (gameList.length == 151) {
      print('doneeee');
      print(gameList);
      showFinishDialog();
    }
  }

  showFinishDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: kDialogShape,
            child: Container(
              width: 350.0,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'You finished the quiz with a score of ${getNumber(score)}!',
                        textAlign: TextAlign.center,
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Do you want to try again?',
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                      style: TextStyle(fontSize: 14.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              if (score >= highScore) {
                                highScore = score;
                                save('highScore', highScore);
                                print('save highscore as $highScore');
                              }
                              gameList.clear();
                              score = 0;
                              startList =
                                  new List<int>.generate(151, (i) => i + 1);
                              showTextField = false;
                              Navigator.pop(context);
                              restore();
                              getElementInit();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  child: Image.asset('images/top2.png'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Yes!',
                                    style: kBallPixelStyleSub,
                                    textScaleFactor: 1,
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  child: Image.asset('images/bottom.png'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              if (score >= highScore) {
                                highScore = score;
                                save('highScore', highScore);
                                print('save highscore as $highScore');
                              }
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  child: Image.asset('images/top2.png'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'No!',
                                    textScaleFactor: 1,
                                    style: kBallPixelStyleSub,
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  child: Image.asset('images/bottom.png'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  playSound(sound) {
    GameController.play('${sound.toString()}.wav');
  }

  Future<void> onSubmit2() {
    var numberLast = gameList.last;
    return validatePokemon(numberLast, pokemon).then((value) async {
      print('this is the answered question $value');
      if (value == true) {
        setState(() {
          score = score + 1;
        });
        getElement();
      } else {
        getElement();
      }
    });
  }

  static Future<bool> validatePokemon(int number, String pokemon) async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance
          .collection('tunes')
          .where('number', isEqualTo: number)
          .limit(1)
          .get()
          .then((doc) {
        final List<DocumentSnapshot> documents = doc.docs;
        documents.forEach((data) async {
          if (data.data()['pokemon'].toString().toLowerCase() ==
              pokemon.toLowerCase()) {
            exists = true;
          } else {
            print('wrong!');
            exists = false;
          }
        });
        return exists;
      });
      return exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  String getNumber(int number) {
    if (number < 10) {
      return '00$number';
    } else if (number < 100) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  save(String key, dynamic value) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPrefs.setBool(key, value);
    } else if (value is String) {
      sharedPrefs.setString(key, value);
    } else if (value is int) {
      sharedPrefs.setInt(key, value);
    } else if (value is double) {
      sharedPrefs.setDouble(key, value);
    } else if (value is List<String>) {
      sharedPrefs.setStringList(key, value);
    }
  }

  restore() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = (sharedPrefs.getInt('highScore') ?? 0);
    });
    print('highscore is $highScore');
  }

  @override
  void initState() {
    getElementInit();
    restore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'High score: ${score >= highScore ? getNumber(score) : getNumber(highScore)}',
          textScaleFactor: 1,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 39,
          ),
          onPressed: () {
            if (showTextField) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: kDialogShape,
                      child: Container(
                        width: 350.0,
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  'Are you sure?',
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                'Going back will stop your current game. Your high score will be saved',
                                textAlign: TextAlign.center,
                                textScaleFactor: 1,
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (score >= highScore) {
                                          highScore = score;
                                          save('highScore', highScore);
                                          print('save highscore as $highScore');
                                        }
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 50,
                                            child:
                                                Image.asset('images/top2.png'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Go back',
                                              style: kBallPixelStyleSub,
                                              textScaleFactor: 1,
                                            ),
                                          ),
                                          Container(
                                            width: 50,
                                            child: Image.asset(
                                                'images/bottom.png'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 50,
                                            child:
                                                Image.asset('images/top2.png'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Stay',
                                              textScaleFactor: 1,
                                              style: kBallPixelStyleSub,
                                            ),
                                          ),
                                          Container(
                                            width: 50,
                                            child: Image.asset(
                                                'images/bottom.png'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              Share.share(
                  'Can you beat my high score of ${score >= highScore ? getNumber(score) : getNumber(highScore)} on PokeTunes? Give it a try! ${await createLink(getNumber(highScore))}');
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 2,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildRow1();
            } else {
              return Column(
                children: [
                  Visibility(
                    visible: !showTextField,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showTextField = true;
                        });
                        Future.delayed(const Duration(milliseconds: 400), () {
                          // getSoundFromList();
                          playSound(gameList.last);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: 100,
                            child: Image.asset('images/top.png'),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Start game!',
                              style: kBallPixelStyleWhite,
                              textScaleFactor: 1,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            width: 100,
                            child: Image.asset('images/bottom.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showTextField,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: PokeBox(
                                padVer: 8.0,
                                padHor: 8.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    initialText,
                                    style: kBallPixelStyle,
                                    textScaleFactor: 1,
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Container(
                                      child: Image.asset('images/grass.png')),
                                ),
                                Positioned(
                                  left: 50,
                                  top: 30,
                                  child: Container(
                                    child: Image.asset(
                                      'gif/${gameList.last}.gif',
                                      color: Colors.black,
                                      width: 50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showTextField,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(child: Image.asset('images/grass.png')),
                            Positioned(
                              left: 45,
                              top: Platform.isAndroid ? 6 : 3,
                              child: Container(
                                child: Image.asset(
                                  'images/ash2.png',
                                  color:
                                      Platform.isAndroid ? Colors.black : null,
                                  // width: 50,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Form(
                                key: _formKey,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: PokeBox(
                                        padHor: 8.0,
                                        padVer: 8.0,
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          textAlign: TextAlign.left,
                                          validator: validateName,
                                          style: kBallPixelStyle,
                                          onSaved: (String value) {
                                            pokemon = value;
                                          },
                                          onFieldSubmitted: (string) {
                                            if (_formKey.currentState
                                                .validate()) {
                                              setState(() {
                                                _formKey.currentState.save();
                                                _controller.clear();
                                                onSubmit2();
                                              });
                                            }
                                          },
                                          controller: _controller,
                                          decoration: InputDecoration(
                                              errorStyle: kBallPixelStyle,
                                              suffixIcon: IconButton(
                                                icon: Image(
                                                  image: AssetImage(
                                                      'images/ball2.png'),
                                                ),
                                                onPressed: () {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    setState(() {
                                                      _formKey.currentState
                                                          .save();
                                                      _controller.clear();
                                                      onSubmit2();
                                                    });
                                                  }
                                                },
                                              ),
                                              labelText: 'Pokemon:',
                                              labelStyle: kBallPixelStyleSub,
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                    PokeBox(
                                      padVer: 8.0,
                                      padHor: 8.0,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              'SCORE: ${getNumber(score)}',
                                              textScaleFactor: 1,
                                              textAlign: TextAlign.center,
                                              style: kBallPixelStyle,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                playSound(gameList.last);
                                              },
                                              child: Text(
                                                'REPLAY TUNE',
                                                style: kBallPixelStyle,
                                                textScaleFactor: 1,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape: kDialogShape,
                                                        child: Container(
                                                          width: 350.0,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    'Are you sure?',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    textScaleFactor:
                                                                        1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10.0,
                                                                ),
                                                                Text(
                                                                  'You\'re about to stop your current game and you will be send back to the home screen. Your high score will be saved',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  textScaleFactor:
                                                                      1,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14.0),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (score >=
                                                                              highScore) {
                                                                            highScore =
                                                                                score;
                                                                            save('highScore',
                                                                                highScore);
                                                                            print('save highscore as $highScore');
                                                                          }
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              width: 50,
                                                                              child: Image.asset('images/top2.png'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                'Stop game',
                                                                                style: kBallPixelStyle,
                                                                                textScaleFactor: 1,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 50,
                                                                              child: Image.asset('images/bottom.png'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              width: 50,
                                                                              child: Image.asset('images/top2.png'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                'Continue',
                                                                                textScaleFactor: 1,
                                                                                style: kBallPixelStyle,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: 50,
                                                                              child: Image.asset('images/bottom.png'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text(
                                                'STOP',
                                                style: kBallPixelStyle,
                                                textScaleFactor: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  _buildRow1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Test your PokeTunes knowledge!',
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              height: 1.7,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Quiz yourself on the 151 PokeTunes! Fill in the Pokemon\'s name and press the ball to check',
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
