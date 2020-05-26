import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:knesset_odata/model/navigation.model.dart';
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

  searchQueryValue(value) {
    print(value);
  }

  searchReset() {}

  buildScreen(
      T viewModel, BuildContext context, BoxConstraints viewportConstraints) {}

  deinit() {}
}

class ScreenComponetState<T extends ScreenViewModel>
    extends State<ScreenComponet> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  final changeNotifier = new StreamController.broadcast();
  @override
  void dispose() {
    widget.deinit();
    _searchQueryController.dispose();
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "חפש...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
      onSubmitted: (value) => {
        widget.searchQueryValue(value),
        setState(() {
          _isSearching = false;
        })
      },
    );
  }

  _buildActions(List<Widget> filterComponent) {
    if (_isSearching) {
      filterComponent.add(IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (_searchQueryController == null ||
              _searchQueryController.text.isEmpty) {
            Navigator.pop(context);
            return;
          }
          _clearSearchQuery();
        },
      ));
    } else
      filterComponent.add(IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ));
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    widget.searchReset();
    setState(() {
      _isSearching = false;
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  buildContent(
      T viewModel, BuildContext context, BoxConstraints viewportConstraints) {
    final bool rtl = viewModel.language == "he";
    final Map<String, dynamic> screenData = viewModel.screenData != null
        ? viewModel.screenData[widget.screenName]
        : {"title": "Home"};
    final String title = screenData["title"];
    final double transformMenu = -8.0;
    bool _searchEnabled = screenData["search"] == true;
    List<Widget> menuItems = <Widget>[];
    if (FAB_ENABLED && screenData["filter"]) {
      menuItems.add(IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            _showDialog(context, viewModel);
            changeNotifier.sink.add(null);
          }));
      menuItems.add(IconButton(
          icon: Icon(Icons.timeline),
          onPressed: () {
            //viewModel.changeCurrentLanguage("he");
            Navigator.pushNamed(context, Routes.timeScreen);
            changeNotifier.sink.add(null);
          }));
      menuItems.add(IconButton(
          icon: Icon(Icons.library_books),
          onPressed: () {
            viewModel.loadBill();
            Navigator.pushNamed(context, Routes.billScreen);
            changeNotifier.sink.add(null);
          }));
      menuItems.add(IconButton(
          icon: Icon(Icons.label_important),
          onPressed: () {
            viewModel.loadLaw();
            Navigator.pushNamed(context, Routes.lawScreen);
            changeNotifier.sink.add(null);
          }));
    }

    FabCircularMenu menu = menuItems.length > 0
        ? FabCircularMenu(
            shouldTriggerChange: changeNotifier.stream,
            ringDiameter: 200,
            transform: rtl
                ? Matrix4.translationValues(transformMenu, 0.0, 0.0)
                : Matrix4.translationValues(-transformMenu, 0.0, 0.0),
            alignment: rtl ? Alignment.bottomLeft : Alignment.bottomRight,
            children: menuItems)
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
    if (_searchEnabled) {
      _buildActions(filterComponent);
    }
    final scaffold = Scaffold(
        drawer: MENU_ENABLED ? NavDrawer(title) : null,
        appBar: AppBar(
            leading: screenData["filter"] == false && _isSearching == false
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Keys.navKey.currentState
                          .pushReplacementNamed(Routes.homeScreen);
                    })
                : Container(),
            title: _isSearching && _searchEnabled
                ? _buildSearchField()
                : Text(title),
            actions: filterComponent),
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
