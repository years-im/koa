# dart-koa

- 基于Dart语言实现的后端框架
- 借鉴了Node.js koa框架的api设计
- 实现了中间件和context，可自由开发中间件

## 安装
#### 添加依赖 在pubspec.yaml文件中的dependencies添加
```yaml
  koa: ^0.0.1
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
    koa: ^0.0.1
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

## 文档
#### koa实例方法
- Koa.use 使用中间件

- Koa.listen 端口绑定
  ```dart
  app.listen(3030, callback: () {
    print('服务启动成功');
  });
  ```

- Koa.onError 错误处理（koa在执行过程中出现异常都会执行此方法）
  ```dart
  app.onError((error) {
    print(error);
  });
  ```

### 上下文 Context API
- HttpRequest httpRequest - dart vm 原生HttpRequest
- Request request (请求)
  - method
    - 类型: ```String```
    - 说明: 获取请求类型
  - path
    - 类型: ```String```
    - 说明: 获取请求的url
  - cookies
    - 类型: ```Cookie```
    - 说明: 获取请求的cookie
  - headers
    - 类型: ```HttpHeaders```
    - 说明: 获取请求头
  - query
    - 类型: ```Future<Map<String, dynamic>>```
    - 说明: 获取请求的Query参数
  - body
    - 类型: ```Future<Map<String, dynamic>>```
    - 说明: 获取请求的body参数
  - files
    - 类型 ```Future<Map<String, File>>``` || ```Future<Map<String, List<File>>>```
    - 说明: 获取上传的文件如果是单个文件上传类型为```Future<Map<String, File>>```, 多个文件上传时候为``Future<Map<String, List<File>>>```
- Response response (响应)
  - status
    - 类型: ```int```
    - 说明: 设置响应状态，如果设置了```body```默认为```200```
  - json
    - 类型: ```Map<String, dynamic>```
    - 说明: 返回```json```对象
  - string
    - 类型: ```String```
    - 说明: 返回字符串
  - file
    - 类型: ```File```
    - 说明: 返回文件
  - headers
    - 类型: ```HttpHeaders```
    - 说明: 设置响应头
  - cookies
    - 类型: ```Cookie```
    - 说明: 设置```Cookie```
  - session
    - 类型: ```HttpSession```
    - 说明: 设置```session```

### 中间件开发
