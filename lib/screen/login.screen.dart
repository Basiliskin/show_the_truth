import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/login.viewmodel.dart';
import 'package:knesset_odata/view/error.dialog.dart';
import 'package:knesset_odata/view/login.form.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title, this.viewModel}) : super(key: key);

  final String title;
  final LoginViewModel viewModel;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Widget getLoadingIndicator(LoginViewModel viewModel) {
    if (viewModel.isLoading) {
      return new CircularProgressIndicator();
    }

    return new Container();
  }

  showLoginError() {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ErrorDialog('API request failed, please try again'));
  }

  Widget buildContent(LoginViewModel viewModel) {
    final _loginUser = (String username, String password) =>
        {viewModel.login(username, password)};
    return new Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Image.asset(
              "assets/image/logo.png",
              width: 300,
              height: 150,
            ),
          ),
          getLoadingIndicator(viewModel),
          LoginInputForm(onLoginValidationSuccess: _loginUser),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: new StoreConnector<AppState, LoginViewModel>(
            converter: (store) => LoginViewModel.fromStore(store),
            builder: (_, viewModel) => buildContent(viewModel),
            onDidChange: (viewModel) {
              if (viewModel.loginError) {
                showLoginError();
              }
            },
          ));
        },
      ),
    );
  }
}
