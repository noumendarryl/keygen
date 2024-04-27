import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keygen/constants/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:keygen/database/database_connection.dart';
import 'package:keygen/view/edit_view.dart';
import 'package:keygen/view/link_account.dart';
import 'package:keygen/widgets/obscuring_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SavedPasswords extends StatefulWidget {
  final List<Map<String, dynamic>> rows;
  const SavedPasswords({Key? key, required this.rows}) : super(key: key);

  @override
  State<SavedPasswords> createState() => _SavedPasswordsState();
}

class _SavedPasswordsState extends State<SavedPasswords> {
  int _itemCount = 0;
  int get itemCount => _itemCount;

  void _downloadPDF() async {
    try {
      // Retrieve all data from Sqflite database
      final rows = await DatabaseConnection.instance.queryAllRows();

      // Convert data to 2D array of strings
      final List<List<String>> tableData = [
        ['ID', 'Site', 'Username', 'Password'],
        ...rows.map((row) => [
              row[DatabaseConnection.columnId].toString(),
              row[DatabaseConnection.columnSite],
              row[DatabaseConnection.columnUsername],
              row[DatabaseConnection.columnPassword]
            ]),
      ];

      // Create PDF document and add table to it
      final pdfWidgets.Document pdf = pdfWidgets.Document();
      pdf.addPage(pdfWidgets.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pdfWidgets.TableHelper.fromTextArray(data: tableData),
        ],
      ));

      // Save PDF document to device storage
      final directory = await FilePicker.platform.getDirectoryPath();
      final file = File('$directory/passwords.pdf');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes.toList());

      AwesomeDialog(
        context: context,
        width: 500.0,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'You did it',
        titleTextStyle: const TextStyle(
          fontSize: 23.0,
        ),
        desc: 'PDF downloaded successfully',
        descTextStyle: const TextStyle(
          fontSize: 18.0,
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
        buttonsTextStyle: const TextStyle(
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ).show();
    } catch (e) {
      // Display error alert
      AwesomeDialog(
        context: context,
        width: 500.0,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'Oops...',
        titleTextStyle: const TextStyle(
          fontSize: 23.0,
        ),
        desc: 'Cannot save file cause no path provided',
        descTextStyle: const TextStyle(
          fontSize: 18.0,
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
        buttonsTextStyle: const TextStyle(
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ).show();
    }
  }

  String getFaviconUrl(String url) {
    String faviconUrl = '';
    if (url.isNotEmpty) {
      Uri uri = Uri.parse(url);
      faviconUrl = uri.replace(path: '/favicon.ico').toString();
      return faviconUrl;
    } else {
      return faviconUrl;
    }
  }

  void refreshUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseConnection.instance.queryAllRows(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        _itemCount = snapshot.data!.length;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                children: [
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Akaya Kanadaka',
                          fontSize: 25.0,
                          color: secondaryColor,
                        ),
                        children: [
                          const TextSpan(
                            text: 'All Saved (',
                          ),
                          TextSpan(
                            text: '$itemCount',
                            style: const TextStyle(color: Colors.blue),
                          ),
                          const TextSpan(text: ')')
                        ]),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _downloadPDF,
                        icon: const Icon(Icons.save_alt),
                        iconSize: 27.0,
                        color: secondaryColor,
                      ),
                      IconButton(
                        onPressed: () async {
                          await DatabaseConnection.instance.deleteAllRows();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear_all_outlined),
                        iconSize: 30.0,
                        color: tertiaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              height: 400.0,
              child: ListView.separated(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final data = snapshot.data?[index];
                  final id = data?[DatabaseConnection.columnId];
                  final websiteUrl = data?[DatabaseConnection.columnSite];
                  final username = data?[DatabaseConnection.columnUsername];
                  final password = data?[DatabaseConnection.columnPassword];
                  final createdAt = data?[DatabaseConnection.columnCreatedAt];
                  final faviconUrl = getFaviconUrl(websiteUrl);
                  final _createdAt =
                      DateFormat('dd/MM/y, hh:mm a').format(createdAt);
                  return FutureBuilder(
                    builder: (context, snapshot) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: faviconUrl.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (await canLaunchUrl(
                                          Uri.parse(websiteUrl))) {
                                        await launchUrl(Uri.parse(websiteUrl));
                                      }
                                    },
                                    child: faviconUrl.isNotEmpty
                                        ? FutureBuilder(
                                            future:
                                                http.get(Uri.parse(faviconUrl)),
                                            builder: (context, snapshot) {
                                              try {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.none ||
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .waiting ||
                                                    snapshot.hasError) {
                                                  return const SizedBox(
                                                    width: 25.0,
                                                    height: 25.0,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: Image.network(
                                                      faviconUrl,
                                                      width: 25.0,
                                                      height: 25.0,
                                                    ));
                                              } catch (e) {
                                                return AlertDialog(
                                                  content: Text('$e'),
                                                );
                                              }
                                            },
                                          )
                                        : null,
                                  ),
                                  const SizedBox(
                                    width: 40.0,
                                  ),
                                ],
                              )
                            : null,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 19.0,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        ),
                        subtitle: ObscuringText(
                          password: password,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _createdAt,
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Color.fromRGBO(39, 50, 58, .6),
                              ),
                            ),
                            const SizedBox(
                              width: 50.0,
                            ),
                            IconButton(
                              icon: const Icon(Icons.link_outlined),
                              color: Colors.blue,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return LinkAccount(
                                        id: id,
                                        site: websiteUrl,
                                        username: username,
                                        password: password,
                                        refreshCallback: refreshUI,
                                      );
                                    });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.grey,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EditView(
                                        id: id,
                                        password: password,
                                        refreshCallback: refreshUI,
                                      );
                                    });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () async {
                                await DatabaseConnection.instance.delete(id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        );
      },
    );
  }
}
