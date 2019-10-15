import 'package:koa/context.dart';

typedef MiddlewareCallback (Context ctx, Function() next);

Function compose(List<MiddlewareCallback> middlewares) {
  return (ctx) async {
    // 当前执行标记
    int index = -1;

    dispatch(int i) async {
      // 判断是否重复调用
      if (i <= index) {
        throw FormatException('next() called multiple times');
      }

      index = i;

      if (i < middlewares.length) {
        final MiddlewareCallback callback = middlewares[i];

        await callback(ctx, () async {
          await dispatch(i + 1);
        });
      }
    }

    await dispatch(0);
  };
}
