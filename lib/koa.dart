library koa;

import 'dart:io';
import 'dart:async';
import 'package:koa/utils/compose.dart';
import 'package:koa/context.dart';
import 'package:koa/utils/statuses.dart';
import 'package:koa/utils/send-file.dart';

export 'package:koa/context.dart';

class Koa {
  // 中间件
  final List<MiddlewareCallback> _middlewares = [];
  // 创建上下文方法
  final _createContext;
  // 异常回掉函数
  Function(dynamic error) _onError;

  Koa({ Context Function(HttpRequest httpRequest) createContext }): _createContext = createContext;

  // 添加中间件
  Koa use(MiddlewareCallback callback) {
    _middlewares.add(callback);
    return this;
  }

  // 监听请求
  Future<HttpServer> listen(int prot, { Function callback }) async {
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, prot);

    server.listen((HttpRequest request) async {
      this._handleRequest(request);
    });

    if (callback != null) {
      callback();
    }

    return server;
  }

  // 异常处理
  void onError(Function(dynamic error) callbacl) {
    _onError = callbacl;
  }

  // 请求处理
  void _handleRequest(HttpRequest request) async {
    // 判断是否自动创建Context
    final Context ctx = _createContext == null ? Context(request) : _createContext(request);
    // 生成中间件串联调用
    final fn = compose(_middlewares);

    // 执行中间件
    try {
      await fn(ctx);
    } catch (error) {
      if (_onError is Function) {
        ctx.onError();
        _onError(error);
      } else {
        rethrow;
      }
    }

    scheduleMicrotask(() {
      _handleResponse(ctx);
    });
  }

  // 响应
  void _handleResponse(Context ctx) {
    final response = ctx.response;
    final httpRequest = ctx.httpRequest;
    if (response.body == null) {
      final String body = codeMessage[response.status.toString()];
      httpRequest.response..write(body)..close();
      return;
    } else if (response.body is File) {
      sendFile(ctx.httpRequest.response, response.body);
    } else {
      httpRequest.response..write(response.body)..close();
    }
  }
}
