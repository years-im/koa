import 'dart:io';
import 'package:koa/request.dart';
import 'package:koa/response.dart';

export 'package:koa/request.dart';
export 'package:koa/response.dart';

class Context {
  final HttpRequest httpRequest;
  // 请求对象
  final Request request;
  // 相应对象
  final Response response;

  Context(this.httpRequest):
    request = Request(httpRequest),
    response = Response(httpRequest);

  onError() {
    response.status = 500;
  }
}
