import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:isolate';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'widgets/tiles_widget.dart';

class TaskInfo {
  final String name;
  final String link;
  final String thumbnailUrl;
  final String size;
  final String ext;
  final String format;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  TaskInfo(
      {this.name,
      this.link,
      this.thumbnailUrl,
      this.size,
      this.ext,
      this.format});
}

class DownloadScreen extends StatefulWidget {
  final TargetPlatform platform;

  DownloadScreen({Key key, this.platform}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  int current = 6;
  List<int> items = <int>[1, 2, 3, 4, 5];
  List<TaskInfo> tasks = List<TaskInfo>();
  ReceivePort _port = ReceivePort();
  ReceivePort _downloadPort = ReceivePort();
  String savingDir;

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
    _bindBackgroundIsolate();
    _setDownloadPort();
    prepare();
  }

  void prepare() async {
    savingDir = await _findLocalPath();
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('download_port');
    send.send([id, status, progress]);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'data_send_port');
    if (!isSuccess) {
      print("couldn't create port");
      _unbindBackgroundIsolate('data_send_port');
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      print("jddkv,pefv");
      TaskInfo newTask = TaskInfo(
          name: data[0],
          link: data[1],
          thumbnailUrl: data[2],
          ext: data[3],
          size: data[4],
          format: data[5]);
      this.initTask(newTask);
      final _tasks = await FlutterDownloader.loadTasks();
      print(newTask.taskId);

      setState(() {
        tasks.add(newTask);
      });
    });
  }

  void _setDownloadPort() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _downloadPort.sendPort, 'download_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate('download_port');
      _setDownloadPort();
      return;
    }
    _downloadPort.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      print("progress $progress");
      final task =
          tasks?.firstWhere((task) => task.taskId == id, orElse: () => null);
      if (task != null) {
        setState(() {
          print(status);
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate('download_port');
    _unbindBackgroundIsolate('data_send_port');
    super.dispose();
  }

  void _unbindBackgroundIsolate(String portName) {
    IsolateNameServer.removePortNameMapping(portName);
  }

  void initTask(TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
      url: task.link,
      savedDir: savingDir,
      fileName: task.name + '.' + task.ext,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    await print(task.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Downloads",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
            appBar: AppBar(
              title: Text('Downloads'),
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Color(0xf1f1f8FF),
              ),
              child: Center(
                child: (tasks.length == 0)
                    ? Container(
                        child: Center(
                        child: Text("No tasks"),
                      ))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          var task = tasks[index];
                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: CardTileTest(
                              title: task.name,
                              size: task.size,
                              thumbnailUrl: task.thumbnailUrl,
                              ext: task.ext,
                              status: task.status,
                              format: task.format,
                              progress: task.progress / 100.0,
                            ),
                            actions: <Widget>[
                              IconSlideAction(
                                caption:
                                    task.status == DownloadTaskStatus.running
                                        ? "Pause"
                                        : "Play",
                                color: Colors.indigo,
                                icon: task.status == DownloadTaskStatus.running
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                onTap: () {
                                  if (task.status ==
                                      DownloadTaskStatus.running) {
                                    FlutterDownloader.pause(
                                        taskId: task.taskId);
                                  } else {
                                    setState(() async {
                                      tasks[index].taskId =
                                          await FlutterDownloader.resume(
                                              taskId: task.taskId);
                                    });
                                  }
                                },
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption:
                                    task.status == DownloadTaskStatus.canceled
                                        ? 'Retry'
                                        : 'Cancel',
                                color: Colors.black45,
                                icon: task.status == DownloadTaskStatus.canceled
                                    ? Icons.refresh
                                    : Icons.cancel,
                                onTap: () {
                                  if (task.status !=
                                      DownloadTaskStatus.canceled) {
                                    FlutterDownloader.cancel(
                                        taskId: task.taskId);
                                  } else {
                                    setState(() async {
                                      tasks[index].taskId =
                                          await FlutterDownloader.retry(
                                              taskId: tasks[index].taskId);
                                    });
                                  }
                                },
                              ),
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  FlutterDownloader.pause(taskId: task.taskId);
                                  setState(() => {tasks.removeAt(index)});
                                },
                              ),
                            ],
                          );
                        }),
              ),
            )));
  }
}
