import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/user.dart';
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
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  User user = User('', '');
  bool hasData = false;

  @override
  void initState() {
    Hive.openBox('app').then((box) {
      final result = box.get('user');

      if (result != null) {
        setState(() {
          user = UserModel.fromJson(json.decode(result));
          hasData = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Hive Example'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Visibility(
                  visible: hasData,
                  child: Column(
                    children: [
                      Text(
                        'Dados Salvos',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text('Usuário: ${user.username}'),
                      Text('Senha: ${user.password}'),
                      SizedBox(height: 24)
                    ],
                  ),
                ),
                Text(
                  'Insira alguns dados para salvar com o hive',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 36),
                  child: TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Usuário'),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 28),
                  child: TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                      label: Text('Senha'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Visibility(
                        visible: hasData,
                        child: Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final box = await Hive.openBox('app');

                              await box.clear();

                              await box.close();

                              setState(() {
                                hasData = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.red[800]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text("Limpar"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: hasData,
                        child: SizedBox(width: 8),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (userController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                              final box = await Hive.openBox('app');

                              user = User(userController.text, passwordController.text);

                              await box.put('user', json.encode(UserModel.toJson(user)));

                              box.close();

                              userController.clear();
                              passwordController.clear();

                              setState(() {
                                hasData = true;
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text("Salvar"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
