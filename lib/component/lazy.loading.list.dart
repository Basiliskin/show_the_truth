import 'dart:async';

import 'package:flutter/material.dart';

typedef Future<List<dynamic>> NextPageCallback(int mode);
typedef void SearchCallback(String value);

class LazyList extends StatefulWidget {
  final NextPageCallback onUpdate;
  final SearchCallback onSearch;
  final Stream shouldTriggerChange;
  LazyList(this.onUpdate, this.shouldTriggerChange, this.onSearch);
  @override
  _LazyListState createState() => _LazyListState();
}

class _LazyListState extends State<LazyList> {
  List<dynamic> items = [];
  bool _isLoading = true;
  bool _hasMore = true;
  StreamSubscription streamSubscription;

  Future<List<dynamic>> fetch() async {
    List<dynamic> list = await widget.onUpdate(items.length == 0 ? 1 : 0);
    return list;
  }

  _search(_) {
    widget.onSearch(_);
    items = [];
    _loadMore();
  }

  _init() {
    streamSubscription = widget.shouldTriggerChange.listen((_) => _search(_));
    _isLoading = true;
    _hasMore = true;
    new Future.delayed(const Duration(seconds: 2), () {
      _loadMore();
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void reassemble() {
    _init();
    super.reassemble();
  }

  @override
  didUpdateWidget(LazyList old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerChange != old.shouldTriggerChange) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerChange.listen((_) => _search(_));
    }
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
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
