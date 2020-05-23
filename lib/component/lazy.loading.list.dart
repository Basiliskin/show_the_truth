import 'package:flutter/material.dart';

typedef Future<List<dynamic>> NextPageCallback(int mode);

class LazyList extends StatefulWidget {
  final NextPageCallback onUpdate;
  LazyList(this.onUpdate);
  @override
  _LazyListState createState() => _LazyListState();
}

class _LazyListState extends State<LazyList> {
  List<dynamic> items = [];
  bool _isLoading = true;
  bool _hasMore = true;
  Future<List<dynamic>> fetch() async {
    List<dynamic> list = await widget.onUpdate(items.length == 0 ? 1 : 0);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    new Future.delayed(const Duration(seconds: 2), () {
      _loadMore();
    });
  }

  _loadMore() {
    _isLoading = true;
    fetch().then((List<dynamic> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          items.addAll(fetchedList);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _hasMore ? items.length + 1 : items.length,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            if (!_isLoading) {
              _loadMore();
            }
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 24,
                width: 24,
              ),
            );
          }
          final item = items[index];
          return Card(child: item.buildItem(context));
        });
  }
}
