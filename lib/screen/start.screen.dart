import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/start.viewmodel.dart';
import 'package:knesset_odata/view/error.dialog.dart';

class StartScreen extends StatefulWidget {
  final Function(StartViewModel viewModel) loadFirebase;
  StartScreen({Key key, this.title, this.viewModel, this.loadFirebase})
      : super(key: key);

  final String title;
  final StartViewModel viewModel;

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  Future<String> loadState(StartViewModel viewModel) =>
      Future.delayed(Duration(seconds: 1), () {
        if (viewModel.isLoading == 1) widget.loadFirebase(viewModel);
        return 'Loaded';
      });

  Widget getLoadingIndicator(StartViewModel viewModel) {
    if (viewModel.isLoading > 0) {
      return new CircularProgressIndicator();
    }
    return new Container();
  }

  showError() {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ErrorDialog(widget.viewModel.errorMessage));
  }

  Widget buildContent(StartViewModel viewModel) {
    List<Widget> children;
    children = <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 50, bottom: 50.0),
        child: Image.asset(
          "assets/image/logo.png",
          width: 300,
          height: 150,
        ),
      ),
      getLoadingIndicator(viewModel)
    ];
    final future = loadState(viewModel);

    return FutureBuilder<String>(
        future: future, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        });
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: viewportConstraints.maxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                      child: new StoreConnector<AppState, StartViewModel>(
                    converter: (store) => StartViewModel.fromStore(store),
                    builder: (_, viewModel) => buildContent(viewModel),
                    onDidChange: (viewModel) {
                      if (viewModel.errorMessage.isNotEmpty) {
                        showError();
                      }
                    },
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
