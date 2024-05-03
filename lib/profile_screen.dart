import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:encrypt/encrypt.dart' as encrypter;
import 'package:fyp_healthcare_app/setting_screen.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:path/path.dart' as path;

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

    var databasesPath2 = await getDatabasesPath();
    String databasePath2 = join(databasesPath2, 'SQMS.db');
    List<int> dbBytes = await File(databasePath2).readAsBytes();

    String dbBytesBase64 = base64Encode(dbBytes);

    final encryption2 = encrypter.Encrypter(encrypter.AES(key));
    final encrypted2 = encryption2.encrypt(dbBytesBase64, iv: ivv);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final File file = File('$selectedDirectory/$username.dat');
      await file.writeAsBytes(encrypted.bytes);

      final File file2 = File('$selectedDirectory/SQMS_db.dat');
      await file2.writeAsBytes(encrypted2.bytes);
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
      if (path.basename(filePath!) == 'SQMS_db.dat') {
        Uint8List encryptedBytes = await File(filePath).readAsBytes();
        final encrypter.Encrypter encryption =
            encrypter.Encrypter(encrypter.AES(key));

        final encrypted = encrypter.Encrypted(encryptedBytes);
        final decrypted = encryption.decrypt(encrypted, iv: ivv);

        List<int> dbBytes = base64Decode(decrypted);

        var databasesPath = await getDatabasesPath();
        String databasePath = path.join(databasesPath, 'SQMS.db');

        await File(databasePath).writeAsBytes(dbBytes);

        Fluttertoast.showToast(
          msg: "Successfully imported the data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Uint8List encryptedBytes = await File(filePath!).readAsBytes();
        final encrypter.Encrypter encryption =
            encrypter.Encrypter(encrypter.AES(key));

        final encrypted = encrypter.Encrypted(encryptedBytes);
        final decrypted = encryption.decrypt(encrypted, iv: ivv);

        final decryptedData = jsonDecode(decrypted);
        updateUsername(decryptedData['username']);

        Fluttertoast.showToast(
            msg: "Sucessfully import the profile ${decryptedData['username']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
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
      backgroundColor: Colors.grey.withOpacity(0.15),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (const SettingScreen())));
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background/splash_background.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  Image.asset(
                    'assets/icon/avatar.png',
                    height: 140,
                    width: 140,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 200.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textFieldController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 17.0, height: 1, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            developer.log(_textFieldController.text,
                                name: "debug.profile");
                            updateUsername(_textFieldController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    SettingsGroup(
                      iconItemSize: 20,
                      items: [
                        SettingsItem(
                          onTap: () {
                            developer.log("import profile pressed",
                                name: "debug.profile");
                            importProfile();
                          },
                          icons: Icons.input_rounded,
                          iconStyle: IconStyle(backgroundColor: Colors.green),
                          title: 'Import profile',
                        ),
                        SettingsItem(
                          onTap: () {
                            exportProfile();
                          },
                          icons: Icons.output_rounded,
                          iconStyle: IconStyle(backgroundColor: Colors.green),
                          title: 'Export profile',
                        ),
                      ],
                    ),
                    SettingsGroup(
                      iconItemSize: 20,
                      items: [
                        SettingsItem(
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: "This app is developed by JQ01c-23",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                fontSize: 16.0);
                          },
                          icons: Icons.info_rounded,
                          iconStyle: IconStyle(
                            backgroundColor: Colors.blue,
                          ),
                          title: 'About',
                          subtitle: "Learn more about this app",
                        ),
                      ],
                    ),
                    SettingsGroup(
                      iconItemSize: 30,
                      settingsGroupTitle: "Account",
                      items: [
                        SettingsItem(
                          onTap: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Reset profile'),
                              content: const Text(
                                  'All sleep data include statistics and readings will be reset. Are you sure you want to reset your profile?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // delete profile
                                    Navigator.pop(context, 'Cancel');
                                  },
                                  child: const Text('Comfirm'),
                                ),
                              ],
                            ),
                          ),
                          icons: Icons.restore,
                          title: "Reset profile",
                          titleStyle: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SettingsItem(
                          onTap: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Delete profile'),
                              content: const Text(
                                  'All sleep data include statistics and readings will be deleted. Are you sure you want to delete your profile?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // delete profile
                                    Navigator.pop(context, 'Cancel');
                                  },
                                  child: const Text('Comfirm'),
                                ),
                              ],
                            ),
                          ),
                          icons: Icons.delete_forever_rounded,
                          title: "Delete profile",
                          titleStyle: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
