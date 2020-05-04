import 'package:knesset_odata/model/redux/reducer/config.reducer.dart';
import 'package:knesset_odata/model/redux/reducer/knesset.reducer.dart';
import 'package:knesset_odata/model/redux/reducer/screen.reducer.dart';
import 'package:knesset_odata/model/redux/reducer/user.reducer.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';

AppState appReducer(AppState state, action) {
  return AppState(
      userState: userReducer(state.userState, action),
      configState: configReducer(state.configState, action),
      screenState: screenReducer(state.screenState, action),
      knessetState: knessetReducer(state.knessetState, action));
}
