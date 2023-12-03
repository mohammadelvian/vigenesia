import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:org/Constant/const.dart';
import 'package:org/Screens/EditPage.dart';
import 'Login.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:org/Models/Motivasi_Model.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  final String? iduser;

  const MainScreens({Key? key, this.nama, this.iduser}) : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = 'http://localhost/vigenesia/';

  var dio = Dio();
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": isi,
      "iduser": widget.iduser ?? '' //sudah ok
      //"iduser": widget.iduser
    };

    try {
      Response response = await dio.post("$baseurl/api/dev/POSTmotivasi/",
          data: body,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => true,
          ));
      print("Respon -> ${response.data} + ${response.statusCode}");
      return response;
    } catch (e) {
      print("Error di -> $e");
    }
  }

  Future<List<MotivasiModel>> getData() async {
    var response = await dio.get('$baseurl/api/Get_motivasi/');

    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> _getData() async {
    setState(() {
      // getData();
    });
  }

  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hallo  ${widget.nama}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        child: Icon(Icons.logout),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (BuildContext context) => new Login(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    controller: isiController,
                    name: "isi_motivasi",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        await sendMotivasi(isiController.text.toString())
                            .then((value) => {
                                  if (value != null)
                                    {
                                      Flushbar(
                                        message: "Berhasil Submit",
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.greenAccent,
                                        flushbarPosition: FlushbarPosition.TOP,
                                      ).show(context)
                                    },
                                  _getData(),
                                  print("Sukses"),
                                  // Navigator.push(
                                  //     context,
                                  //     new MaterialPageRoute(
                                  //       builder: (BuildContext context) =>
                                  //           EditPage(),
                                  //     )) Editan sendiri
                                });
                      },
                      child: Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
