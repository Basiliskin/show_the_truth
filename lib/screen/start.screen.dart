import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/start.viewmodel.dart';
import 'package:knesset_odata/view/error.dialog.dart';
import 'package:knesset_odata/widget/wave.progress.dart';

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
      return WaveProgress(180.0, Colors.blue, Colors.blueAccent, 40.0);
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
        padding: EdgeInsets.only(top: 80, bottom: 80.0),
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
