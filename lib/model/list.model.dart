import 'dart:math';
import 'package:knesset_odata/component/stars.component.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:flutter/material.dart';
import 'package:knesset_odata/util/widget.to.image.dart';

final _random = new Random();
int next(int min, int max) => min + _random.nextInt(max - min);

abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildItem(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildItem(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline1,
    );
  }
}

class _MemberDescription extends StatelessWidget {
  _MemberDescription({Key key, this.member}) : super(key: key);

  final KnesetMember member;

  @override
  Widget build(BuildContext context) {
    final Text city = member.cityName != ""
        ? Text(
            '(${member.cityName})',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          )
        : Text('');
    int totalDone = 0;

    member.stats.entries.forEach((f) => {totalDone += f.value["done"]});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(children: <Widget>[city]),
              Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Text(
                    'כנסת :',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${member.knessetNums.length}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 2.0, right: 2.0)),
                  Text(
                    'תפקידים/מפלגות :',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${member.positionCount}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'הצעות :',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${member.total}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 2.0, right: 2.0)),
                  Text(
                    ', אושרו :',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalDone',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String combine(String a, String b) {
  if (a != null && b != null && a != "" && b != "") {
    return a + " / " + b;
  }
  if (a != null && a != "") return a;
  if (b != null && b != "") return b;
  return "";
}

class KnesetMemberListItem extends StatelessWidget {
  KnesetMemberListItem({Key key, this.thumbnail, this.member})
      : super(key: key);

  final Widget thumbnail;
  final KnesetMember member;

  @override
  Widget build(BuildContext context) {
    final KnessetChartImageWidget chart = new KnessetChartImageWidget(member);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 120,
        width: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: Column(children: <Widget>[
                            thumbnail,
                            Text(
                              '${member.fullName}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ])),
                      Center(child: StarRating(rating: member.stars))
                    ],
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: _MemberDescription(member: member),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class KnesetMemberItem implements ListItem {
  final KnesetMember member;
  KnesetMemberItem(this.member);
  Widget buildImage(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print(member.imgPath);
      },
      child: Container(
          width: 72,
          height: 72,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 72,
              minHeight: 72,
              maxWidth: 72,
              maxHeight: 72,
            ),
            child: member.imgPath != ""
                ? Image.network(member.imgPath, fit: BoxFit.cover)
                : next(1, 5) % 2 == 1
                    ? Image.asset("assets/image/avatarB.png")
                    : Image.asset("assets/image/avatarA.png"),
          )));
  Widget buildItem(BuildContext context) {
    return KnesetMemberListItem(
        thumbnail: Container(child: buildImage(context)), member: member);
  }
}
