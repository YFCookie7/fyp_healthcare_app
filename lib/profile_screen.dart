import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_healthcare_app/onboarding_screen.dart';
import 'package:fyp_healthcare_app/splash_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:encrypt/encrypt.dart' as encrypter;
import 'package:fyp_healthcare_app/setting_screen.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:path/path.dart' as path;
import 'package:fyp_healthcare_app/database.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    _textFieldController.text = username!;
  }

  Future<void> updateUsername(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
    _textFieldController.text = newName;

    Fluttertoast.showToast(
        msg: "Username updated to $newName",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  Future<void> exportProfile() async {
    // get username
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    // get database
    var databasesPath = await getDatabasesPath();
    String databasePath = join(databasesPath, 'SQMS.db');
    List<int> dbBytes = await File(databasePath).readAsBytes();

    String dbBytesBase64 = base64Encode(dbBytes);

    final encryption = encrypter.Encrypter(encrypter.AES(key));
    final encrypted = encryption.encrypt(dbBytesBase64, iv: ivv);

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
      PlatformFile file = result.files.first;
      String username = file.name.split('.').first;
      updateUsername(username);
      String? filePath = result.files.single.path;
      developer.log("${result.files.single.path}", name: "debug.profile");
      Uint8List encryptedBytes = await File(filePath!).readAsBytes();
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
                      settingsGroupTitle: "Backup",
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
                      iconItemSize: 30,
                      settingsGroupTitle: "Account",
                      items: [
                        // SettingsItem(
                        //   onTap: () => showDialog<String>(
                        //     context: context,
                        //     builder: (BuildContext context) => AlertDialog(
                        //       title: const Text('Reset profile'),
                        //       content: const Text(
                        //           'All sleep data include statistics and readings will be reset. Are you sure you want to reset your profile?'),
                        //       actions: <Widget>[
                        //         TextButton(
                        //           onPressed: () =>
                        //               Navigator.pop(context, 'Cancel'),
                        //           child: const Text('Cancel'),
                        //         ),
                        //         TextButton(
                        //           onPressed: () {
                        //             // delete profile
                        //             deleteDatabaseFile();
                        //             Navigator.pop(context, 'Cancel');
                        //           },
                        //           child: const Text('Comfirm'),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        //   icons: Icons.restore,
                        //   title: "Reset profile",
                        //   titleStyle: const TextStyle(
                        //     color: Colors.red,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
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
                                  onPressed: () async {
                                    // delete profile
                                    Navigator.pop(context, 'Cancel');
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.clear();

                                    deleteDatabaseFile();
                                    initDatabase();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SplashScreen()));
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
                    SettingsGroup(
                      iconItemSize: 20,
                      items: [
                        SettingsItem(
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: "This app is developed by team JQ01c-23",
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
