import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_server/http_server.dart';

abstract class FormFile<T> {
  // 文件数据
  T get value;
}

class FormDataFile implements FormFile<HttpMultipartFormData> {
  final HttpMultipartFormData value;

  FormDataFile(this.value);

  // name
  String get name => value.contentDisposition.parameters['filename'];

  // type
  String get type => value.contentType.toString();

  // 写入文件
  Future<File> write(String path) async {
    final file = File(path);
    final IOSink sink = file.openWrite();

    // 文本
    if (value.isText) {
      final stream = value.cast<String>();
      await for (String item in stream) {
        sink.write(item);
      }
    } else {
      final Stream<List<int>> stream = value.cast<List<int>>();
      await for (List<int> item in stream) {
        sink.add(item);
      }
    }

    await sink.flush();
    await sink.close();
    return file;
  }
}

class Request {
  final HttpRequest httpRequest;
  List<int> _bytes;
  // body参数
  Map<String, dynamic> _body;
  // 文件
  Map<String, dynamic> _files;

  Request(this.httpRequest);

  // method
  String get method => httpRequest.method;

  // path
  String get path => httpRequest.uri.path;

  // cookies
  List<Cookie> get cookies => httpRequest.cookies;

  // session
  HttpSession get session => httpRequest.session;

  // headers
  HttpHeaders get headers => httpRequest.headers;

  // query
  Map<String, dynamic> get query => httpRequest.uri.queryParameters;

  // body
  Future<Map<String, dynamic>> get body async {
    final String contentType = httpRequest.headers.contentType.toString();

    if (_body == null) {
      final data = await _getRequestBodybytes();

      // 类型判断
      switch(contentType) {
        // json
        case 'application/json': {
          _body = _parseJson(data);
        }
        break;

        // x-www-form-urlencoded
        case 'application/x-www-form-urlencoded': {
          _body = _parseUrlencoded(data);
        }
        break;

        // form data
        default: {
         _body = await _parseFormData(data);
        }
      }
    }
    return _body;
  }

  // files
  Future<Map<String, dynamic>> get files async {
    if (_files == null) {
      final List<int> data = await _getRequestBodybytes();
      _files = {};

      if (data.length > 0) {
        final multiparts = await _parseMultipar(data);

        for (HttpMultipartFormData multipart in multiparts) {
          final parameters = multipart.contentDisposition.parameters;
          final String key = parameters['name'];
          final String fileName = parameters['filename'];

          // 过滤掉非文件类型
          if (fileName != null) {
            final data = FormDataFile(multipart);
            if (_files[key] == null) {
              _files[key] = data;
            } else if (_files[key] is List) {
              (_files[key] as List).add(data);
            } else {
              _files[key] = [_files[key], data];
            }
          }
        }
      }
    }

    return _files;
  }

  // 请求的body
  Future<List<int>> _getRequestBodybytes() async {
    if (_bytes == null) {
      final BytesBuilder bytes = await httpRequest.fold(BytesBuilder(), (BytesBuilder builder, List<int> data) => builder..add(data));
      _bytes = bytes.takeBytes();
    }

    return _bytes;
  }

  Future<List<HttpMultipartFormData>> _parseMultipar(List<int> data) async {
    final List<HttpMultipartFormData> multiparts = [];
    final String boundary = httpRequest.headers.contentType.parameters['boundary'];
    final bodyStream = Stream<List<int>>.fromIterable(<List<int>>[data]);
    final transformer = MimeMultipartTransformer(boundary);
    final stream = transformer.bind(bodyStream);

    await for (MimeMultipart params in stream) {
      final HttpMultipartFormData multipart = HttpMultipartFormData.parse(params);
      multiparts.add(multipart);
    }

    return multiparts;
  }

  // 解析json
  Map<String, dynamic> _parseJson(List<int> data) {
    final String dataString = utf8.decode(data);
    return jsonDecode(dataString) as Map;
  }

  // 解析urlencoded
  Map<String, dynamic> _parseUrlencoded(List<int> data) {
    final Map<String, dynamic> body = {};
    final String dataString = utf8.decode(data);
    // 将数据分割
    final List<String> dataList = dataString.split('&');

    dataList.forEach((String item) {
      // 分割key value
      final List<String> list = item.split('=');
      final String key = list.first;

      if (list.length == 2) {
        body[key] = list.last;
      } else {
        body[key] = null;
      }
    });

    return body;
  }

  // 解析form data
  Future<Map<String, dynamic>> _parseFormData(List<int> data) async {
    final Map<String, dynamic> formData = {};
    final multiparts = await _parseMultipar(data);

    // 过滤掉文件类型
    for (HttpMultipartFormData multipart in multiparts) {
      final parameters = multipart.contentDisposition.parameters;
      final String key = parameters['name'];
      final String fileName = parameters['filename'];

      if (multipart.isText && fileName == null) {
        formData[key] = await multipart.join();
      }
    }

    return formData;
  }
}
