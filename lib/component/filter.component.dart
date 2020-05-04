import 'package:flutter/material.dart';
import 'package:knesset_odata/component/vertical.tab.component.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/viewmodel/screen.viewmodel.dart';

class ListItem {
  final String name;
  final List list;
  final String category;
  ListItem(this.category, this.name, this.list);
}

class TabItem {
  final String name;
  final List list;
  final String category;
  TabItem(this.category, this.name, this.list);
}

class FilterPanel extends StatefulWidget {
  final ScreenViewModel viewModel;
  final Function(Map<String, bool>) onFilter;
  final Function() onResetFilter;
  FilterPanel(this.viewModel, this.onFilter, this.onResetFilter);
  @override
  FilterPanelState createState() => new FilterPanelState();
}

class FilterPanelState extends State<FilterPanel> {
  Map<String, bool> isSelected;
  TextEditingController editingController = TextEditingController();
  List<String> keywords = [];
  @override
  void initState() {
    isSelected = null;
    keywords = [];
    super.initState();
  }

  @override
  void reassemble() {
    isSelected = null;
    keywords = [];
    super.reassemble();
  }

  Widget _tabsContent(String name, BuildContext context, List<KeyValue> items) {
    final orientation = MediaQuery.of(context).orientation;
    String key;

    items.forEach((v) => {
          key = "$name|${v.name}",
          isSelected[key] =
              isSelected.containsKey(key) ? isSelected[key] : false
        });
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
      itemBuilder: (BuildContext context, int index) {
        KeyValue item = items[index];
        String itemKey = "$name|${item.name}";
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
                value: isSelected[itemKey],
                onChanged: (value) {
                  setState(() {
                    isSelected[itemKey] = !isSelected[itemKey];
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green),
            Text(
              item.name,
              style: TextStyle(color: Colors.black, fontSize: 12.0),
            )
          ],
        );
      },
    );
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        keywords = query.split(" ");
      });
    } else {
      setState(() {
        keywords = [];
      });
    }
  }

  TabItem _filter(MapEntry<String, ListItem> item) {
    ListItem value = item.value;
    if (keywords.length > 0) {
      String exists = keywords.firstWhere(
          (word) => value.name.indexOf(word) >= 0,
          orElse: () => null);
      if (exists != null)
        return TabItem(value.category, value.name, value.list);
      List newList = value.list
          .where((i) =>
              keywords.firstWhere((word) => i.name.indexOf(word) >= 0,
                  orElse: () => null) !=
              null)
          .toList();
      if (newList.length > 0)
        return TabItem(value.category, value.name, newList);
      return null;
    }
    return TabItem(value.category, value.name, value.list);
  }
  /*
  _getSelected() {
    List<MapEntry<String, bool>> d =
        isSelected.entries.where((e) => e.value).toList();
    return d.map((f) => f.key).toList();
  }
  */

  @override
  Widget build(BuildContext context) {
    if (isSelected == null) isSelected = widget.viewModel.filter;
    final List knessetMember = widget.viewModel.knessetState.knessetMember;
    final List members = knessetMember
        .map((m) => KeyValue<String>(m.fullName, m.fullName))
        .toList();
    final KnessetFilter filter = widget.viewModel.knessetState.knessetFilter;
    final List<Widget> contents = new List<Widget>();
    final List<Tab> tabs = new List<Tab>();
    filter.year.sort((a, b) => a.value - b.value);
    List<KeyValue<String>> stars = [
      KeyValue<String>("0+", "0"),
      KeyValue<String>("1+", "1"),
      KeyValue<String>("2+", "2"),
      KeyValue<String>("3+", "3"),
      KeyValue<String>("4+", "4"),
    ];
    final Map<String, ListItem> nameMapping = {
      "stars": ListItem("stars", "דירוג", stars),
      "fullName": ListItem("fullName", "שם", members),
      "birthCountry": ListItem("birthCountry", "מדינה", filter.birthCountry),
      "cityName": ListItem("cityName", "עיר", filter.cityName),
      //"faction": ListItem("faction", "מפלגה", filter.faction),
      "firstLetter": ListItem("firstLetter", "א-ב", filter.firstLetter),
      "gender": ListItem("gender", "מין", filter.gender),
      "knesset": ListItem("knesset", "כנסת", filter.knessetId),
      //"knessetYears": ListItem("knessetYears", "שנה", filter.year)
    };

    List<TabItem> tabList = [];
    nameMapping.entries.forEach((e) => {tabList.add(_filter(e))});
    tabList.where((item) => item != null).toList().forEach((t) => {
          tabs.add(Tab(child: Text(t.name, style: TextStyle(fontSize: 12.0)))),
          contents.add(_tabsContent(t.category, context, t.list))
        });
// set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("ביטל"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = FlatButton(
      child: Text("אישור"),
      onPressed: () {
        widget.onFilter(isSelected);
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget resetButton = FlatButton(
      child: Text("איפוס סננים"),
      onPressed: () {
        setState(() {
          widget.onResetFilter();
          isSelected = {};
        });
        //Navigator.of(context).pop(); // dismiss dialog
      },
    );
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(
        children: <Widget>[
          TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              controller: editingController,
              decoration: InputDecoration(
                  labelText: "חיפוש",
                  hintText: "חיפוש",
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(3.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0))))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5.0)),
          Container(
            width: 320,
            height: 360,
            child: VerticalTabs(
              tabsWidth: 80,
              direction: TextDirection.ltr,
              contentScrollAxis: Axis.vertical,
              changePageDuration: Duration(milliseconds: 500),
              tabs: tabs,
              contents: contents,
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[continueButton, cancelButton]),
          resetButton
        ],
      )),
    );
  }
}
