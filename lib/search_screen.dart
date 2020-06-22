import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/tiles_widget.dart';

Future<List<Video>> createVideoList(String title) async {
  final http.Response response = await http.post(
    "http://localhost:5000/result-mob",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'url': 'https://www.youtube.com/watch?v=nmnTAOU44SI',
      'file_type': 'audio',
    }),
  );

  if (response.statusCode == 200) {
    print('Here');
    var videosJson = json.decode(response.body);
    List<Video> videos = [];
    for (int i = 0; i < videosJson['formats'].length; i++) {
      videos.add(
        Video.fromJson(videosJson['formats'][i], videosJson['title'],
            videosJson['thumbnail']),
      );
    }
    return videos;
//    return Video.fromJson(json.decode(response.body)['formats'][0]);
  } else {
    print(response.statusCode);
    throw Exception('Failed to fetch data');
  }
}

class Video {
  final String url;
  final String title;
  final String size;
  final String thumbnailUrl;
  final String ext;
  final String format;
  Video(
      {this.url,
      this.title,
      this.size,
      this.thumbnailUrl,
      this.ext,
      this.format});

  factory Video.fromJson(
      Map<String, dynamic> json, String title, String thumbnailUrl) {
    return Video(
      url: json['url'],
      size: json['filesize'],
      title: title,
      thumbnailUrl: thumbnailUrl,
      ext: json['ext'],
      format: json['format'],
    );
  }
}

class SearchScreen extends StatefulWidget {
  final TargetPlatform platform;
  SearchScreen({this.platform});
  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Future<List<Video>> _futureVideoList;
  final SendPort send = IsolateNameServer.lookupPortByName('data_send_port');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testing the downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Testing the downloader'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureVideoList == null)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Video url'),
                    ),
                    RaisedButton(
                      child: Text('Search'),
                      onPressed: () {
                        setState(() {
                          _futureVideoList = createVideoList(_controller.text);
                        });
                      },
                    ),
                  ],
                )
              : FutureBuilder<List<Video>>(
                  future: _futureVideoList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Video vid = snapshot.data[index];
                          return Column(
                            children: <Widget>[
                              InkWell(
                                child: MediaFilesTile(
                                  title: vid.title,
                                  size: vid.size,
                                  thumbnailUrl: vid.thumbnailUrl,
                                  format: vid.format,
                                  ext: vid.ext,
                                ),
                                onTap: () async {
                                  print("sending ..");
                                  send.send([
                                    vid.title,
                                    vid.url,
                                    vid.thumbnailUrl,
                                    vid.ext,
                                    vid.size,
                                    vid.format,
                                  ]);
                                },
                              ),
                              SizedBox(
                                height: 6,
                              ),
                            ],
                          );
                        },
                      );
//                      return Text(snapshot.data.title.toString());
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return CircularProgressIndicator();
                  },
                ),
        ),
      ),
    );
  }
}
