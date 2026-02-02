///学习记录
///https://www.foooor.com/Dart/03-%E8%AF%AD%E5%8F%A5.html
///https://www.foooor.com/Dart/07-%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1-1.html

import 'dart:math'; //导入库

void main() {
  var aaa = 'hellodart'; //自动推断类型，之后无法更改
  print(aaa); //自动换行
  String ccc = "String类型";
  String ccc1 = '我想说${aaa}'; //插值
  print(ccc);
  print(ccc1);

  const pi = 3.1415926535; //编译时初始化
  print(pi);
  final a = new DateTime.now(); //运行时初始化
  print(a);

  dynamic som = "helloworld"; //可以动态修改类型
  som = 322;
  print(som);

  print(aaa.runtimeType); //.runtimeType获取类型
  // ignore: unnecessary_type_check
  bool ddd = aaa is String; //is判断类型

  double dddd = 0.9;
  int iii = dddd.toInt(); //dtoi类型转换
  iii = dddd.round(); //四舍五入
  ccc = iii.toString();
  iii = int.parse(ccc); //int转String String转int

  String? s1 = null; //?表示为可空类型，并赋值为空
  String s2 = s1 ?? ccc; //??表示若s1为空则取ccc，否则取s1
}

// 函数
int add(int a, int b) {
  return a + b;
}

int add2(int a, {int? ss1}) {
  //命名可选参数{} 调用时可以直接用 add2(1, ss1: 2)传值 添加required字段表示必须传递
  int c = a + (ss1 ?? 0);
  return c;
}

int add3(int a, [int? ss1]) {
  //位置可选参数[] 调用时根据位置传值，需要用null占位
  return a + (ss1 ?? 0);
}
// 命名可选和位置可选均可以提供默认值

// 容器
void container() {
  List<int> numbers = [1, 2, 3];
  List<int> list1 = List.filled(5, 1); //定长为5，初始化为1，不能添加元素
  numbers.add(4); //添加元素
  numbers[0] = 1; //下标引用
  print(numbers.length); //获取长度
  numbers.insert(0, 1);
  numbers.insert(0, [9, 8] as int); //插入元素或数组
  numbers.remove(0); //删除元素0
  numbers.contains(1); //检查是否包含元素1

  Set<int> set1 = {1, 2, 3}; //不能重复，不能下标引用，可存储不同类型
  var numbers2 = <int>{}; // 等价于 Set<int> numbers2 = {};
  numbers2.add(1);
  var set2 = {1, 2, 3};
  var set3 = {3, 4, 5};
  var unionset = set2.union(set3); //set的优势在于取逻辑运算，如取并集
  var intersectionset = set2.intersection(set3); //取交集
  var differenceset = set2.difference(set3); //取set2对set3的差集

  Map<String, int> map1 = {'a': 1, 'b': 2}; //map是元素对，前元素是键key，后元素是值value
  map1['c'] = 3; //添加元素，用key作为下标引用
  map1.remove('a'); //删除'a'键及所对应的元素
  //map的3种遍历方法
  for (var ent1 in map1.entries) {
    var key = ent1.key;
    var value = ent1.value;
  }
  for (var key in map1.keys) {
    var value = map1[key];
  }
  map1.forEach((key, value) {
    print("$key, $value");
  });
  print(map1.containsKey('a')); //检查键是否包含'a'
}

//类
class Person {
  late String name; //late表示延迟初始化 因为String，int为非空类型
  late int age;
  void sayHello() {
    print("你好，我是${name}，今年$age岁。");
  }

  Person(String name, int age) {
    //构造函数 等效Person(this.name, this.age);
    this.name = name;
    this.age = age;
  }
} //比较像结构体
//封装
//_可以定义私有变量和私有函数，不同文件之间不能直接访问私有变量和私有函数
//还可以通过定义函数（get set）的方式在外部间接访问私有变量

//继承 继承父类的变量和函数
class Student2 extends Person {
  late int grade;
  Student2(String name, int age, int grade) : super('', 0) {
    this.name = name;
    this.age = age;
    this.grade = grade;
  }
}

//多态
//父对象当成框架，子对象当成执行机关
//那么在主要功能中就可以保持父对象不变，扩展子对象的类别

//实际上此时的父对象就是一个抽象类，可在class前加上abstract
//但是一个子对象只能继承一个父对象，如果要有多个父亲，此时接口充当伪父对象（相当于附加方法）
//下面是一个例子
// 定义一个抽象类
abstract class Bird {
  void tweet();
}

// 定义一个接口
abstract class Animal {
  void breathe();
}

// 定义一个接口
abstract class Helpful {
  void help();
}

class Sparrow extends Bird implements Animal, Helpful {
  @override
  void breathe() {
    print("我要呼吸");
  }

  @override
  void tweet() {
    print("我会啾啾叫");
  }

  @override
  void help() {
    print("有益的");
  }
}

void main() {
  Animal animal = Sparrow();
  animal.breathe();
}

//json 是一种数据存贮方式
//可以使用dart:convert库中的jsonEncode()函数将map转换为json，用String储存
//反之，用jsonDecode()将json转换为map<String,dynamic>
//一般的使用方法是在所属的类中定义一个map类型的tojson函数，返回相应格式的map数据

//泛型函数 不限制类型就是 也可以用extends字段约束类型
//获取列表的最后一个元素
T getLast<T>(List<T> list) {
  return list[list.length - 1];
}

void main() {
  List<int> intList = [1, 2, 3];
  List<String> strList = ['a', 'b', 'c', 'd'];

  int i = getLast<int>(intList);
  print(i);

  String s = getLast<String>(strList);
  print(s);
}

//pub包管理库
//使用pubspec.yaml文件管理
/*
name: hello_dart # 项目名称
description: My Dart application # 项目描述
version: 1.0.0  # 项目版本

environment:  # 指定sdk版本约束
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  http: ^0.13.6

dev_dependencies:
  # 添加开发时需要的依赖包，如果有的话
*/
//如果有两个库名字相同，则可使用as起别名
//用show和hide限制导入的函数

//异步 一个程序卡住/需要等待时，继续运行其他程序
/*Dart中是使用 单线程 + 事件循环 来实现异步操作的。
在单线程模型维护着一个事件循环（Event Loop），
当有网络请求、文件读写IO操作等事件时，会将这些事件加入到事件队列中，
事件循环会不断的从事件队列中取出事件并处理，直到事件队列清空。*/

main() {
  var future1 = requestNetwork(); //创建Future对象，将requestNetwork抛到队列之中
  future1
      .then((value) {
        //等到运行完毕，then开始执行
        print("请求结果:$value");
      })
      .catchError((error) {
        print("捕获异常:$error");
      });

  print("main end");
}

Future<String> requestNetwork() {
  return new Future(() {
    sleep(Duration(seconds: 3)); // 休眠3秒，模拟从网络获取数据

    throw Exception("网络请求出现错误");
  });
}

//使用async和await实现更简洁统一（相对于同步格式而言）的主函数结构
main() {
  var future2 = requestNetwork();
}

Future<String> requestNetwork() async {
  await Future.delayed(Duration(seconds: 3));
}
