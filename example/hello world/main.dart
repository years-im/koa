import 'package:koa/koa.dart';

main() {
  final Koa app = Koa();

  app.use((ctx, next) {
    ctx.response.string = 'hello world';
  });

  app.onError((error) {
    print(error);
  });

  app.listen(3333, callback: () {
    print('服务启动成功: http://localhost:3333');
  });
}
