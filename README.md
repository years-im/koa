# dart koa

- 基于Dart语言实现的后端框架
- 借鉴了Node.js koa框架的api设计
- 实现了中间件和context，可自由开发中间件

## 安装
#### 添加依赖 在pubspec.yaml文件中的dependencies添加
```yaml
$ koa: ^0.0.1
```
#### 执行安装依赖
```ssh
$ pub get
```

## 来写一个 Hello World
#### 运行需要Dart环境, 可以点击 [Dart环境搭建](https://dart.dev/get-dart) 查看和下载SDK
#### 创建一个文件夹, 并且创建一个 pubspec.yaml 文件
```ssh
$ mkdir dart-koa
$ touch ./dart-koa/pubspec.yaml
```

#### 编辑pubspec.yaml内容
```yaml
  name: 项目名称
  version: 0.0.1
  environment:
    sdk: '>=2.3.0 <3.0.0'
  dependencies:
    koa: any
```
#### 进入项目目录
```ssh
$ cd ./dart-koa
```

#### 在项目目录中执行安装依赖
```ssh
$ pub get
```
### 代码编写
```ssh
$ mkdir lib
$ touch lib/main.dart
```
### 编辑内容
```dart
import 'package:koa/koa.dart';

main() {
  final Koa app = Koa();

  app.use((ctx, next) {
    ctx.response.string = 'hello world';
  });

  app.listen(3030, callback: () {
    print('服务启动成功');
  });
}
```
### 启动服务
```ssh
$ dart lib/main.dart
```
#### 现在打开浏览器访问 http://localhost:3030 就能看到内容啦！