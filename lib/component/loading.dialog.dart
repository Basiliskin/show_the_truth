import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/loading.viewmodel.dart';

class ModalRoundedProgressBar extends StatefulWidget {
  final double opacity;
  final String textMessage; // optional message to show
  ModalRoundedProgressBar({
    @required this.textMessage, // some text to show if needed...
    this.opacity, // opacity default value
  });

  @override
  State createState() => _ModalRoundedProgressBarState();
}

//StateClass ...
class _ModalRoundedProgressBarState extends State<ModalRoundedProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: new StoreConnector<AppState, LoadingViewModel>(
            converter: (store) => LoadingViewModel.fromStore(store),
            builder: (_, viewModel) => buildContent(viewModel)));
  }

  Widget buildContent(LoadingViewModel viewModel) {
    if (viewModel.isLoading == 0) return Stack();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: widget.opacity ?? 0.7,
            //ModalBarried used to make a modal effect on screen
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(widget.textMessage),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// handler class
class ProgressBarHandler {
  Function show; //show is the name of member..can be what you want...
  Function dismiss;
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
