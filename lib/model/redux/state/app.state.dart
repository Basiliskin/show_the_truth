import 'package:meta/meta.dart';
import 'package:knesset_odata/model/redux/state/config.state.dart';
import 'package:knesset_odata/model/redux/state/knesset.state.dart';
import 'package:knesset_odata/model/redux/state/screen.state.dart';
import 'package:knesset_odata/model/redux/state/user.state.dart';
import 'package:knesset_odata/util/common.dart';
import 'package:knesset_odata/util/request.dart';

const MOKING_ENABLED = true;
const FIREBASE_MOKING_ENABLED = MOKING_ENABLED;
const FAB_ENABLED = true;
const MENU_ENABLED = false;

@immutable
class AppState {
  final UserState userState;
  final ConfigState configState;
  final ScreenState screenState;
  final KnessetState knessetState;

  AppState(
      {@required this.userState,
      @required this.configState,
      @required this.screenState,
      @required this.knessetState});

  factory AppState.initial() {
    return AppState(
        userState: UserState.initial(),
        configState: ConfigState.initial(),
        screenState: ScreenState.initial(),
        knessetState: KnessetState.initial());
  }

  AppState copyWith(
      {UserState userState,
      ConfigState configState,
      ScreenState screenState,
      KnessetState knessetState,
      List<String> filter}) {
    return AppState(
        userState: userState ?? this.userState,
        configState: configState ?? this.configState,
        screenState: screenState ?? this.screenState,
        knessetState: knessetState ?? this.knessetState);
  }

  @override
  int get hashCode => userState.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          userState == other.userState &&
          configState == other.configState &&
          screenState == other.screenState &&
          knessetState == other.knessetState;

  request(url, body, [bool encrypted = false]) async {
    final client = Request();
    Map<String, dynamic> resBody = await client.request(url, body, encrypted);
    prettyPrint(resBody);
    return resBody;
  }
}
