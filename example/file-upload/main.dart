import 'package:koa/koa.dart';

main() {
  final Koa app = Koa();

  app.use((context, next) async {
    final files = await context.request.files;
    final data = await context.request.body;
    final file = files['file'] as FormDataFile;

    print(data);

    if (file != null) {
      final filePath = '/Users/allan/Desktop/allan/${file.name}';
      await file.write(filePath);
      context.response.string = '文件上传成功 $filePath';
    } else {
      context.response.string = '请上传文件';
    }
  });

  app.listen(3030, callback: () {
    print('服务启动成功: http://localhost:3030');
  });
}
