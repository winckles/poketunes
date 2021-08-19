import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

var kDialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(13.0),
);

var kBallPixelStyleTitle = TextStyle(
    fontFamily: Platform.isAndroid ? 'Roboto' : 'Pokemon Pixel',
    fontSize: Platform.isAndroid ? 18 : 24);
var kBallPixelStyleSub = TextStyle(
    fontFamily: Platform.isAndroid ? 'Roboto' : 'Pokemon Pixel',
    fontSize: Platform.isAndroid ? 16 : 20,
    color: Colors.black);
var kBallPixelStyle = TextStyle(
    fontFamily: Platform.isAndroid ? 'Roboto' : 'Pokemon Pixel',
    fontSize: Platform.isAndroid ? 16 : 20);
var kBallPixelStyleWhite = TextStyle(
    fontFamily: Platform.isAndroid ? 'Roboto' : 'Pokemon Pixel',
    fontSize: Platform.isAndroid ? 16 : 20,
    color: Colors.white);

class SettingsLa {
  static const String guess = 'Guess the Pokemon!';
  static const String version = 'Version';

  static const List<String> settings = <String>[guess, version];
}

String validateName(String value) {
  if (value.length == 0)
    return 'This field cannot be empty';
  else
    return null;
}

List stringList = [
  'What was that noise? It sounded like ...',
  'Oh no I heard something! It\'s ...!',
  'What pokemon could this be?',
  'Woow that was loud! What pokemon was that?',
  'Eeny, meeny, miny, moe..',
  'Is it a bird? Is it a plane? No it\'s...',
  'WOW, very noise, much curiosity, so ...',
  'A wild pokemon appeared! And it seems hungry!',
  'A wild pokemon appeared!',
  'Yeey, a pokemon appeared!',
  'Eeeek, a pokemon appeared!!',
  'A pokemon seems to be nearby. Teehee... woman\'s secret!',
  'Hmm, sounds like...?',
];

Future<String> createLink(highScore) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://poketunes.page.link',
    link: Uri.parse('https://poketunes.page.link/download'),
    androidParameters: AndroidParameters(
      packageName: 'com.dutchappfarm.poketunes',
//        minimumVersion: 21,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.dutchappfarm.poketunes',
//        minimumVersion: '2.0.1',
//        appStoreId: '123456789',
    ),
    googleAnalyticsParameters: GoogleAnalyticsParameters(
      campaign: 'example-promo',
      medium: 'social',
      source: 'orkut',
    ),
//      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
//        providerToken: '123456',
//        campaignToken: 'example-promo',
//      ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: 'Beat the high score of $highScore on PokeTunes',
      description:
          'Can you guess all the 151 pokemon\'s tunes correctly? Give it a try!',
      imageUrl: Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/poketunes-eb0e0.appspot.com/o/img-min.png?alt=media&token=ef235727-fa6f-470d-b9a4-af50a710ee34'),
    ),
  );
  final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
  final Uri shortUrl = shortDynamicLink.shortUrl;
  print(shortUrl.toString());
  return shortUrl.toString();
}

Future<String> createLinkPokemon(pokemon) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://poketunes.page.link',
    link: Uri.parse('https://poketunes.page.link/download'),
    androidParameters: AndroidParameters(
      packageName: 'com.dutchappfarm.poketunes',
//        minimumVersion: 21,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.dutchappfarm.poketunes',
//        minimumVersion: '2.0.1',
//        appStoreId: '123456789',
    ),
    googleAnalyticsParameters: GoogleAnalyticsParameters(
      campaign: 'example-promo',
      medium: 'social',
      source: 'orkut',
    ),
//      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
//        providerToken: '123456',
//        campaignToken: 'example-promo',
//      ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: 'Listen to $pokemon\'s tune on PokeTunes',
      description:
          'Can you guess all the 151 pokemon\'s tunes correctly? Give it a try!',
      imageUrl: Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/poketunes-eb0e0.appspot.com/o/img-min.png?alt=media&token=ef235727-fa6f-470d-b9a4-af50a710ee34'),
    ),
  );
  final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
  final Uri shortUrl = shortDynamicLink.shortUrl;
  print(shortUrl.toString());
  return shortUrl.toString();
}
