import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:knesset_odata/component/filter.component.dart';
import 'package:knesset_odata/component/loading.dialog.dart';
import 'package:knesset_odata/model/redux/state/app.state.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';
import 'package:knesset_odata/widget/fab.circular.menu.dart';
import 'package:knesset_odata/widget/nav.drawer.dart';

class ScreenComponet<T extends ScreenViewModel> extends StatefulWidget {
  final String screenName;
  ScreenComponet({Key key, @required this.screenName}) : super(key: key);

  @override
  ScreenComponetState<T> createState() => ScreenComponetState<T>();
  ScreenViewModel viewCreator(Store<AppState> store) {
    return ScreenViewModel.fromStore(store);
  }

  buildScreen(
      T viewModel, BuildContext context, BoxConstraints viewportConstraints) {}
}

class ScreenComponetState<T extends ScreenViewModel>
    extends State<ScreenComponet> {
  final changeNotifier = new StreamController.broadcast();
  @override
  void dispose() {
    changeNotifier.close();
    super.dispose();
  }

  _showDialog(BuildContext context, T viewModel) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        content: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              FilterPanel(
                  viewModel,
                  (items) => {viewModel.onFilterUpdate(items)},
                  () => viewModel.onResetFilter())
            ])));

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  buildContent(
      T viewModel, BuildContext context, BoxConstraints viewportConstraints) {
    final bool rtl = viewModel.language == "he";
    final Map<String, dynamic> screenData = viewModel.screenData != null
        ? viewModel.screenData[widget.screenName]
        : {"title": "Home"};
    final String title = screenData["title"];
    final double transformMenu = -8.0;
    final double padding = 16.0;

    FabCircularMenu menu = FAB_ENABLED
        ? FabCircularMenu(
            shouldTriggerChange: changeNotifier.stream,
            ringDiameter: 200,
            transform: rtl
                ? Matrix4.translationValues(transformMenu, 0.0, 0.0)
                : Matrix4.translationValues(-transformMenu, 0.0, 0.0),
            alignment: rtl ? Alignment.bottomLeft : Alignment.bottomRight,
            children: <Widget>[
                IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      viewModel.changeCurrentLanguage("he");
                      changeNotifier.sink.add(null);
                    }),
                IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () {
                      viewModel.changeCurrentLanguage("en");
                      changeNotifier.sink.add(null);
                    })
              ])
        : null;

    List<Widget> widgetList = new List<Widget>();
    try {
      widgetList
          .add(widget.buildScreen(viewModel, context, viewportConstraints));
    } catch (e) {
      print(e);
    }

    final ModalRoundedProgressBar progressBar = ModalRoundedProgressBar(
        textMessage: screenData["loading"] ?? "Loading");

    List<Widget> filterComponent = <Widget>[];
    if (screenData["filter"]) {
      filterComponent.add(Padding(
          padding: rtl
              ? EdgeInsets.only(left: padding)
              : EdgeInsets.only(right: padding),
          child: GestureDetector(
            onTap: () {
              _showDialog(context, viewModel);
            },
            child: Icon(
              Icons.filter_list,
              size: 26.0,
            ),
          )));
    }

    final scaffold = Scaffold(
        drawer: MENU_ENABLED ? NavDrawer(title) : null,
        appBar: AppBar(
          title: Text(title),
          actions: filterComponent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widgetList,
          ),
        ),
        floatingActionButton: menu);

    return Stack(
      children: <Widget>[
        scaffold,
        progressBar,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: new StoreConnector<AppState, T>(
                  converter: (store) => widget.viewCreator(store),
                  builder: (_, viewModel) =>
                      buildContent(viewModel, context, viewportConstraints)),
            ),
          ),
        );
      },
    );
  }
}
