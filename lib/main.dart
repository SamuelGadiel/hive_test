import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await path.getApplicationDocumentsDirectory();

  Hive.init(directory.path);
  // await Hive.deleteBoxFromDisk('app');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> texts = [];

  void getData() async {
    final box = await Hive.openBox('app');

    final result = box.toMap();

    texts.clear();
    setState(() {
      result.forEach((key, value) {
        print('$key: $value');
        texts.add(value);
      });
    });
  }

  void storeData() async {
    final box = await Hive.openBox('app');

    final time = DateTime.now();

    await box.add('${time.hour}:${time.minute}:${time.second}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: texts.length,
              itemBuilder: (context, index) {
                return Text(texts[index]);
              },
            ),
            SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: storeData,
                  child: Text('add'),
                ),
                ElevatedButton(
                  onPressed: getData,
                  child: Text('refresh'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
