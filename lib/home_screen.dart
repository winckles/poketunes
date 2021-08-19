import 'dart:io' show Platform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poketunes/audio.dart';
import 'package:package_info/package_info.dart';
import 'package:poketunes/constants.dart';
import 'package:poketunes/play_screen.dart';
import 'package:poketunes/poke_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share/share.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String searchResult = '';

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'tech@dutchappfarm.com',
      queryParameters: {'subject': 'PokeTunes feedback'});

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          cursorColor: Colors.redAccent,
          onChanged: (String value) {
            Future.delayed(const Duration(milliseconds: 600), () {
              setState(() {
                searchResult = value;
              });
            });
          },
          controller: _controller,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white),
              hintText: 'Search pokemon..',
              hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videogame_asset),
            onPressed: () {
              Navigator.pushNamed(context, PlayScreen.id);
            },
          ),
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
              return StreamPokeList(searchResult);
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
            'Play one of the 151 PokeTunes!',
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
          RichText(
            textScaleFactor: 1,
            text: TextSpan(
              text: 'Found a better tune? Contact us at ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.7,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'tech@dutchappfarm.com!',
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () => launch(_emailLaunchUri.toString()),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' Version ${_packageInfo.version}'),
              ],
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }
}

class StreamPokeList extends StatelessWidget {
  final String searchResult;
  StreamPokeList(this.searchResult);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tunes')
            .orderBy('number', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.redAccent,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No internet connection',
                    textScaleFactor: 1,
                    style: kBallPixelStyleWhite,
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
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
                      'No data..',
                      textScaleFactor: 1,
                      style: kBallPixelStyleWhite,
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
            );
          } else if (snapshot.hasData && snapshot.data.docs.length == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
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
                      'Couldn\'t find anything..',
                      textScaleFactor: 1,
                      style: kBallPixelStyleWhite,
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
            );
          } else if (snapshot.hasData) {
            List searchList = snapshot.data.docs;

            int _buildSearch() {
              if (searchResult == '') {
                searchList = snapshot.data.docs;
                return searchList.length;
              } else {
                searchList = snapshot.data.docs
                    .where((element) => element
                        .data()['pokemon']
                        .toLowerCase()
                        .contains(searchResult.toLowerCase()))
                    .toList();
                return searchList.length;
              }
            }

            _buildSearch();

            return searchList.length == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 30),
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
                            'Couldn\'t find anything..',
                            textScaleFactor: 1,
                            style: kBallPixelStyleWhite,
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
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: searchList.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot user = snapshot.data.docs[index];
                      if (searchResult == '') {
                        return _buildItem(context, searchList[index]);
                      } else if (user
                          .data()['pokemon']
                          .toLowerCase()
                          .contains(searchResult.toLowerCase())) {
                        return _buildItem(context, searchList[index]);
                      } else {
                        return _buildItem(context, searchList[index]);
                      }
                    });
          } else {
            return Center(
              child: Text(
                'Loading..',
                style: kBallPixelStyleWhite,
              ),
            );
          }
        });
  }

  Widget _buildItem(BuildContext context, DocumentSnapshot user) {
    String getNumber() {
      if (user.data()['number'] < 10) {
        return '#00${user.data()['number']}';
      } else if (user.data()['number'] < 100) {
        return '#0${user.data()['number']}';
      } else {
        return '#${user.data()['number']}';
      }
    }

    return Slidable(
      actionPane: SlidableBehindActionPane(),
      closeOnScroll: true,
      actionExtentRatio: 0.20,
      secondaryActions: [
        IconSlideAction(
          caption: 'Share',
          iconWidget: Icon(
            Icons.share,
            color: Colors.redAccent,
          ),
          color: Color(0xff3C5AA6),
          foregroundColor: Colors.white,
          onTap: () async {
            Share.share(
                'Listen to ${user.data()['pokemon']}\'s tune on PokeTunes. Give it a try! ${await createLinkPokemon(user.data()['pokemon'])}');
          },
        ),
      ],
      child: PokeBox(
        padHor: 7.0,
        padVer: 3.0,
        child: ListTile(
          title: Text(user.data()['pokemon'], style: kBallPixelStyleTitle),
          subtitle: Text(getNumber(), style: kBallPixelStyleSub),
          leading: Stack(
            children: [
              Container(
                height: 26,
                child: Image.asset('images/ball2.png'),
              ),
              Container(
                child: Image.asset(
                  'gif/${user.data()['number'].toString()}.gif',
                  color: Platform.isAndroid ? Colors.black : null,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.play_arrow,
              color: Color(0xff2A75BB),
              size: 30,
            ),
            onPressed: () {
              GameController.play('${user.data()['number'].toString()}.wav');
            },
          ),
        ),
      ),
    );
  }
}
