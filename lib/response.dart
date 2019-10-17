import 'dart:io';
import 'dart:convert';

class Response {
  final HttpRequest httpRequest;
  // 状态是否修改过
  bool _explicitStatus = false;
  // 返回内容
  dynamic _body;

  Response(this.httpRequest) {
    httpRequest.response.statusCode = 404;
  }

  // cookies
  List<Cookie> get cookies => httpRequest.response.cookies;

  // headers
  HttpHeaders  get headers => httpRequest.response.headers;

  // session
  HttpSession get session => httpRequest.session;

  // 获取相应内容
  dynamic get body => _body;

  set body(dynamic body) {
    _body = body;
    if (_explicitStatus == false) status = 200;
  }

  // 获取http状态码
  int get status => httpRequest.response.statusCode;

  // 设置http状态码
  set status(int code) {
    httpRequest.response.statusCode = code;
    _explicitStatus = true;
  }

  // 返回json
  set json(Map<String, dynamic> data) {
    headers.contentType = ContentType.json;
    body = jsonEncode(data);
  }

  // 返回字符串
  set string(String data) {
    headers.contentType = ContentType.text;
    body = data;
  }

  // 返回文件
  set file(File file) {
    body = file;
  }
}
