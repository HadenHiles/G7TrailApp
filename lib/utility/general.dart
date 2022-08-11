import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> getBytesFromUrl(String url, int width) async {
  var iconRequest = await http.get(Uri.parse(url));
  var data = await iconRequest.bodyBytes;

  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}
