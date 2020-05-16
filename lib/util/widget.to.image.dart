import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:knesset_odata/model/kneset.model.dart';
import 'package:knesset_odata/component/chart/knesset.chart.dart';

/// Creates an image from the given widget by first spinning up a element and render tree,
/// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
///
/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
Future<Uint8List> createImageFromWidget(GlobalKey key, Widget widget,
    {Size logicalSize, TextDirection textDirection = TextDirection.ltr}) async {
  try {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      window: null,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner();

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: textDirection,
              child: widget,
            )).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  } catch (e) {
    return null;
  }
}

Future<Uint8List> knessetChartToImage(KnesetMember member, GlobalKey key) {
  final KnessetChart obj = KnessetChart.fromMember(member, true);

  return createImageFromWidget(key, obj, logicalSize: Size(100, 100));
}

class KnessetChartImageWidget extends StatefulWidget {
  final KnesetMember member;

  KnessetChartImageWidget(this.member);
  @override
  State createState() {
    return new KnessetChartImageState();
  }
}

class KnessetChartImageState extends State<KnessetChartImageWidget> {
  Uint8List bytes;
  GlobalKey key = GlobalKey();
  getSize() {
    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    return renderBoxRed.size;
  }

  @override
  Widget build(BuildContext context) {
    if (bytes == null)
      Future.delayed(Duration(milliseconds: 100), () async {
        knessetChartToImage(widget.member, key).then((data) {
          setState(() {
            bytes = data != null ? data.buffer.asUint8List() : null;
          });
        });
      });

    return bytes == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: MemoryImage(bytes), fit: BoxFit.fill)),
          );
  }
}
