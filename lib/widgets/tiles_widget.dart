import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:getflutter/getflutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CardTileTest extends StatelessWidget {
  final String title;
  final String size;
  final String thumbnailUrl;
  final String ext;
  final String format;
  final DownloadTaskStatus status;
  final double progress;

  const CardTileTest(
      {Key key,
      this.title,
      this.size,
      this.thumbnailUrl,
      this.ext,
      this.format,
      this.status,
      this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[100],
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(5, 5), // changes position of shadow
          ),
        ],
      ),
      height: 80,
      child: Stack(children: <Widget>[
        Positioned(
          left: 10,
          top: 13,
          child: GFAvatar(
            backgroundImage: NetworkImage(thumbnailUrl),
            shape: GFAvatarShape.standard,
          ),
        ),
        Positioned(
          top: 15,
          left: 69,
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
          ),
        ),
        Positioned(
          right: 10,
          top: 13,
          child: status != DownloadTaskStatus.canceled
              ? CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 5,
                  percent: progress,
                  animation: true,
                  animateFromLastPercent: true,
                  center: Text(
                    (progress * 100).toStringAsFixed(2) + "%",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: status == DownloadTaskStatus.running
                      ? Colors.green
                      : Colors.grey,
                )
              : Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
        ),
        Positioned(
          top: 35,
          left: 69,
          child: Text(
            "Size: $size",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0),
          ),
        ),
        Positioned(
          top: 50,
          left: 69,
          child: Text(
            "$ext / $format",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0),
          ),
        ),
      ]),
    );
  }
}

class MediaFilesTile extends StatelessWidget {
  final String title;
  final String size;
  final String thumbnailUrl;
  final String ext;
  final String format;

  const MediaFilesTile({
    Key key,
    this.title,
    this.size,
    this.thumbnailUrl,
    this.ext,
    this.format,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[100],
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(5, 5), // changes position of shadow
          ),
        ],
      ),
      height: 80,
      child: Stack(children: <Widget>[
        Positioned(
          left: 10,
          top: 13,
          child: GFAvatar(
            backgroundImage: NetworkImage(thumbnailUrl),
            shape: GFAvatarShape.standard,
          ),
        ),
        Positioned(
          top: 15,
          left: 69,
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
          ),
        ),
        Positioned(
          top: 35,
          left: 69,
          child: Text(
            "Size: $size",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0),
          ),
        ),
        Positioned(
          top: 50,
          left: 69,
          child: Text(
            "$ext / $format",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0),
          ),
        ),
      ]),
    );
  }
}
