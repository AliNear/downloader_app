import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnotherTestWidget extends StatefulWidget {
  AnotherTestWidget({Key key}) : super(key: key);

  @override
  _AnotherTestWidgetState createState() => _AnotherTestWidgetState();
}

class _AnotherTestWidgetState extends State<AnotherTestWidget> {
  // final SendPort send = IsolateNameServer.lookupPortByName('test_send_port');
  void sendData() {
    // send.send([
    //   "Griiiib",
    //   "https://r2---sn-qwx11t-j1ae.googlevideo.com/videoplayback?expire=1592638861&ei=LWntXrGWCcrMW-L5jpAI&ip=129.45.78.210&id=o-APb0QO1A9L9f7FDg2c0QX-SzYaW1z6O2uCXjV1er_WlX&itag=135&aitags=133%2C134%2C135%2C136%2C137%2C160%2C242%2C243%2C244%2C247%2C248%2C278&source=youtube&requiressl=yes&mh=N5&mm=31%2C29&mn=sn-qwx11t-j1ae%2Csn-hgn7yn7e&ms=au%2Crdu&mv=m&mvi=1&pl=24&initcwndbps=236250&vprv=1&mime=video%2Fmp4&gir=yes&clen=42192687&dur=523.689&lmt=1541808220205371&mt=1592617230&fvip=5&keepalive=yes&c=WEB&txp=5533432&sparams=expire%2Cei%2Cip%2Cid%2Caitags%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgHviQv8hNdRXIKiuk22UCZaKU85BF4qiAUl9v9GSV3xUCICh_S-MjSCO7WUO5CUQxRkCbWUQvlQBP7O3hmrrzwcTD&sig=AOq0QJ8wRQIhALGY60MkBn7s3tTkSmXF1XGsY8NnaKFjBmboK7ddyczgAiB5saDnY4ROXY9OgIYIcBtv0g1h9gPBjrsB3sbZMEyFsg==&ratebypass=yes"
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: RaisedButton(
          child: Text("Send"),
          onPressed: () => sendData(),
        ),
      ),
    );
  }
}
