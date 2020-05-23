import 'package:flutter/material.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/model/list.model.dart';
import 'package:knesset_odata/model/navigation.model.dart';

const double imageSize = 32;

class BillListItemData {
  final Map bill;
  final List<KnesetMember> members;
  BillListItemData(this.bill, this.members);

  Widget buildImage(BuildContext context, KnesetMember member) =>
      GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            KnesetMemberItem m = new KnesetMemberItem(member);
            Navigator.pushNamed(context, Routes.memberScreen, arguments: m);
          },
          child: Container(
              width: imageSize,
              height: imageSize,
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: imageSize,
                  minHeight: imageSize,
                  maxWidth: imageSize,
                  maxHeight: imageSize,
                ),
                child: member.imgPath != ""
                    ? Image.network(member.imgPath, fit: BoxFit.cover)
                    : next(1, 5) % 2 == 1
                        ? Image.asset("assets/image/avatarB.png")
                        : Image.asset("assets/image/avatarA.png"),
              )));

  Widget buildDesc(BuildContext context) {
    String name = bill["d:Name"];
    int statusID = bill["d:StatusID"];
    List<Widget> children = <Widget>[];
    if (statusID != 118) {
      children.add(Text(
        bill["d:StatusTypeDesc"],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10.0,
          color: Colors.orange,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    children.add(Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.black54,
        fontWeight: FontWeight.bold,
      ),
    ));
    double cWidth = MediaQuery.of(context).size.width * 0.6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Container(
                  width: cWidth,
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children),
                )
              ]),
              Padding(padding: EdgeInsets.only(bottom: imageSize)),
              Container(
                  height: imageSize,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return this.buildImage(context, members[index]);
                      })),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItem(BuildContext context) {
    int knessetNum = bill["d:KnessetNum"];
    int billID = bill["d:BillID"];

    String date = bill["date"];
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
                            '$knessetNum',
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
                          Text(
                            'ID :',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$billID",
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
                          Text(
                            'תאריך :',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$date",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: buildDesc(context)),
            )
          ],
        ),
      ),
    );
  }
}
