import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

class FireBaseService {
  final FirebaseMessaging _firebaseMessaging =
      FIREBASE_MOKING_ENABLED == false ? FirebaseMessaging() : null;

  final Function(String token) onFirebaseToken;
  final Function(Map<String, dynamic> message) onMessage;
  final Function(Map<String, dynamic> message) onResume;
  final Function(Map<String, dynamic> message) onLaunch;

  FireBaseService(
      {this.onFirebaseToken, this.onMessage, this.onResume, this.onLaunch});

  init() {
    if (FIREBASE_MOKING_ENABLED) return;
    _firebaseMessaging.getToken().then((token) {
      final tokenStr = token.toString();
      onFirebaseToken(tokenStr);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        onMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        onResume(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        onLaunch(message);
      },
    );
  }
}
