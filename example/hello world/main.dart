import 'dart:io';
import 'package:koa/koa.dart';

class AppContext extends Context {
  AppContext(HttpRequest httpRequest): super(httpRequest);

  final message = 'hello world!';
}

main() {
  final app = Koa<AppContext>(createContext: (httpRequest) => AppContext(httpRequest));

  app.use((ctx, next) {
    // 返回上一个中间件添加的message
    ctx.response.string = ctx.message;
  });

  app.onError((error) {
    print(error);
  });

  app.listen(3333, callback: () {
    print('服务启动成功: http://localhost:3333');
  });
}
