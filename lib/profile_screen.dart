import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:encrypt/encrypt.dart' as encrypter;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _textFieldController = TextEditingController();
  final key = encrypter.Key.fromUtf8('32lengthkeyisrequiredhahahahahah');
  final ivv = encrypter.IV.fromBase64("encryptionIVis16");

  @override
  void initState() {
    super.initState();
    getProfileName();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> getProfileName() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'profile.db');

    Database database = await openDatabase(
      path,
      version: 1,
    );

    List<Map> list = await database.rawQuery('SELECT * FROM User');
    String username = list[0]['username'];
    setState(() {
      _textFieldController.text = username;
    });
    await database.close();
  }

  Future<void> updateUsername(String newName) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'profile.db');

    Database database = await openDatabase(
      path,
      version: 1,
    );

    List<Map> list = await database.rawQuery('SELECT * FROM User');
    String oldName = list[0]['username'];

    int count = await database.rawUpdate(
        'UPDATE User SET username = ? WHERE username = ?', [newName, oldName]);
    setState(() {
      _textFieldController.text = newName;
    });
    Fluttertoast.showToast(
        msg: "Username updated to $newName",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
    await database.close();
  }

  Future<void> exportProfile() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'profile.db');

    Database database = await openDatabase(
      path,
      version: 1,
    );

    List<Map> list = await database.rawQuery('SELECT * FROM User');
    String username = list[0]['username'];
    await database.close();

    final String userData = jsonEncode({"username": username});

    final encryption = encrypter.Encrypter(encrypter.AES(key));
    final encrypted = encryption.encrypt(userData, iv: ivv);
    final decrypted = encryption.decrypt(encrypted, iv: ivv);
    developer.log(decrypted, name: "debug.profile");
    developer.log(encrypted.base64, name: "debug.profile");

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final File file = File('$selectedDirectory/$username.dat');
      await file.writeAsBytes(encrypted.bytes);
    }

    Fluttertoast.showToast(
        msg: "Data exported to $selectedDirectory/$username.dat",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> importProfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      developer.log("${result.files.single.path}", name: "debug.profile");

      Uint8List encryptedBytes = await File(filePath!).readAsBytes();
      final encrypter.Encrypter encryption =
          encrypter.Encrypter(encrypter.AES(key));

      final encrypted = encrypter.Encrypted(encryptedBytes);
      final decrypted = encryption.decrypt(encrypted, iv: ivv);

      final decryptedData = jsonDecode(decrypted);
      updateUsername(decryptedData['username']);

      Fluttertoast.showToast(
          msg: "Sucessfully import the data ${decryptedData['username']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Invalid file selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Colors.blue, Colors.purple],
              ),
            ),
            child: const AppBarContent(),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background/splash_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80.0),
                Text(
                  'Profile',
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ));
  }
}

class AppBarContent extends StatelessWidget {
  const AppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: <Widget>[
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'PatuaOne',
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 25,
                ),
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       body: SingleChildScrollView(
  //           child: Column(children: [
  //     const SizedBox(height: 150.0),
  //     Image.asset('assets/icon/avatar.png', width: 130, height: 130),
  //     Padding(
  //       padding: const EdgeInsets.all(50.0),
  //       child: TextField(
  //         controller: _textFieldController,
  //         decoration: const InputDecoration(
  //           labelStyle: TextStyle(color: Colors.blue),
  //           prefixIcon: Icon(
  //             Icons.person,
  //             color: Colors.red,
  //           ),
  //         ),
  //         style: const TextStyle(color: Colors.black),
  //       ),
  //     ),
  //     ElevatedButton(
  //       onPressed: () {
  //         updateUsername(_textFieldController.text);
  //       },
  //       child: const Text('Update name'),
  //     ),
  //     const SizedBox(height: 20.0),
  //     ElevatedButton(
  //       onPressed: () {
  //         exportProfile();
  //       },
  //       child: const Text('Export Profile'),
  //     ),
  //     const SizedBox(height: 20.0),
  //     ElevatedButton(
  //       onPressed: () {
  //         importProfile();
  //       },
  //       child: const Text('Import Profile'),
  //     ),
  //   ])));
  // }

