import 'dart:async';
import 'dart:io';
import 'package:mime/mime.dart';

class _VirtualDirectoryFileStream extends StreamConsumer<List<int>> {
  final HttpResponse response;
  final String path;
  List<int> buffer = [];

  _VirtualDirectoryFileStream(this.response, this.path);

  Future addStream(stream) {
    stream.listen((data) {
      if (buffer == null) {
        response.add(data);
        return;
      }

      if (buffer.isEmpty) {
        if (data.length >= defaultMagicNumbersMaxLength) {
          setMimeType(data);
          response.add(data);
          buffer = null;
        } else {
          buffer.addAll(data);
        }
      } else {
        buffer.addAll(data);
        if (buffer.length >= defaultMagicNumbersMaxLength) {
          setMimeType(buffer);
          response.add(buffer);
          buffer = null;
        }
      }
    }, onDone: () {
      if (buffer != null) {
        if (buffer.isEmpty) {
          setMimeType(null);
        } else {
          setMimeType(buffer);
          response.add(buffer);
        }
      }
      response.close();
    }, onError: response.addError);
    return response.done;
  }

  Future close() => Future.value();

  void setMimeType(List<int> bytes) {
    var mimeType = lookupMimeType(path, headerBytes: bytes);
    if (mimeType != null) {
      response.headers.contentType = ContentType.parse(mimeType);
    }
  }
}

void sendFile(HttpResponse response, File file) {
    file
      .openRead()
      .cast<List<int>>()
      .pipe(_VirtualDirectoryFileStream(response, file.path));
}
