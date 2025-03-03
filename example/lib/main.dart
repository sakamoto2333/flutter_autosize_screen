import 'package:flutter/material.dart';
import 'package:flutter_autosize_screen/auto_size_util.dart';

void main() {
  AutoSizeUtil.setStandard(430, isAutoTextSize: true);
  runAutoApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Autosize Demo',
      builder: AutoSizeUtil.appBuilder,
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextStyle _style = const TextStyle(color: Colors.white);
  final GlobalKey _keyGreen = GlobalKey();
  final GlobalKey _keyBlue = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox =
          _keyGreen.currentContext!.findRenderObject()!.paintBounds;
      final sizeGreen = renderBox.size;
      debugPrint('${sizeGreen.width} ----- ${sizeGreen.height}');

      final renderBlu =
          _keyBlue.currentContext!.findRenderObject()!.paintBounds;
      final sizeBlue = renderBlu.size;
      debugPrint('${sizeBlue.width} ----- ${sizeBlue.height}');
      debugPrint('${AutoSizeUtil.getScreenSize()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final originalSize = view.physicalSize / view.devicePixelRatio;
    final nowDevicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autosize Demo'),
      ),
      body: CustomScrollView(
        physics: const ScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        key: _keyGreen,
                        height: 60,
                        color: Colors.redAccent,
                        child: Text(
                          '使用Expanded平分屏幕',
                          style: _style,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 60,
                        color: Colors.blue,
                        child: Text(
                          '使用Expanded平分屏幕',
                          style: _style,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      key: _keyBlue,
                      width: 180,
                      height: 60,
                      color: Colors.teal,
                      child: Text(
                        '宽度写的是 180',
                        style: _style,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 180,
                      height: 60,
                      color: Colors.grey,
                      child: Text(
                        '宽度写的是 180',
                        style: _style,
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  width: 360,
                  height: 60,
                  color: Colors.purple,
                  child: Text(
                    '宽度写的是 360',
                    style: _style,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('按钮'),
                  ),
                  const SizedBox(width: 20),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('按钮'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('按钮'),
                  ),
                ]),
                const SizedBox(height: 20),
                Text('原始的 逻辑像素: $originalSize '),
                Text('原始的 物理像素: ${view.physicalSize} '),
                Text('原始的 devicePixelRatio: ${view.devicePixelRatio} '),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  width: 360,
                  height: 10,
                  color: Colors.grey,
                ),
                Text('更改后 逻辑像素: ${MediaQuery.of(context).size}  '),
                Text('更改后 devicePixelRatio: $nowDevicePixelRatio'),
                const Spacer(),
                const SafeArea(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '这是输入框',
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
