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
  final String? iduser;
  final String? nama;
  const MainScreens({Key? key, this.iduser, this.nama}) : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = 'http://localhost/vigenesia/';
  String? id;
  var dio = Dio();
  List<MotivasiModel> ass = [];
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": isi,
      "iduser": widget.iduser //sudah ok
      // "iduser": widget.iduser
    };

    try {
      Response response = await dio.post("$baseurl/api/dev/POSTmotivasi/",
          data: body,
          options: Options(contentType: Headers.formUrlEncodedContentType
              // validateStatus: (status) => true,28 vidF
              ));
      print("Respon -> ${response.data} + ${response.statusCode}");

      return response;
    } catch (e) {
      print("Error di -> $e");
    }
  }

  List<MotivasiModel> listproduk = [];

  Future<List<MotivasiModel>> getData() async {
    var response =
        await dio.get('$baseurl/api/Get_motivasi?iduser= ${widget.iduser}');

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

  Future<dynamic> deletePost(String id) async {
    dynamic data = {
      "id": id,
    };
    var response = await dio.delete('$baseurl/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {'Content-type': "application/json"}));

    print("${response.data}");
    var resbody = jsonDecode(response.data);
    return resbody;
  }

//28 vid F
  Future<List<MotivasiModel>> getData2() async {
    var response = await dio.get('$baseurl/api/Get_motivasi');
    print("${response.data}");
    if (response.statusCode == 200) {
      var getUserData = response.data as List;
      var listUsers =
          getUserData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception("Failed To Load");
    }
  }

  Future<void> _getData() async {
    setState(() {
      getData();
      listproduk.clear(); //28 vid F

      // return CircularProgressIndicator(); //28 vid F
    });
  }

  TextEditingController isiController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getData2();
    _getData();
  }

  String? trigger;
  String? triggeruser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Berfungsi agar bisa scroll
        child: SafeArea(
            //agar tidak keluar dari area screen hp
            child: Container(
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
                          ));
                    },
                  ),
                ], //penutup children
              ), // penutup row
              SizedBox(height: 20),
              FormBuilderTextField(
                controller: isiController,
                name: "isi_motivasi",
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(left: 10),
                ),
              ),
              // SizedBox(
              //   height: 40,
              // ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isiController.text.toString().isEmpty) {
                      Flushbar(
                        message: "Tidak Boleh Kosong",
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.redAccent,
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                    } else if (isiController.text.toString().isNotEmpty) {
                      await sendMotivasi(
                        isiController.text.toString(),
                      ).then((value) => (value) => {
                            if (value != null)
                              {
                                Flushbar(
                                  message: "Berhasil Submit",
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.greenAccent,
                                  flushbarPosition: FlushbarPosition.TOP,
                                ).show(context)
                              }
                          });
                    }
                    print("Sukses");
                  },
                  child: Text("Submit"),
                ),
              ),
              // await sendMotivasi(isiController.text.toString())
              // .then((value) => {
              // if (value != null)

              // _getData(),
              // print("Sukses"),
              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //       builder: (BuildContext context) =>
              //           EditPage(),
              //     )) Editan sendiri

              SizedBox(
                height: 40,
              ),
              TextButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  _getData();
                },
              ),
              FormBuilderRadioGroup(
                  onChanged: (value) {
                    setState(() {
                      trigger = value;
                      print("HASILNYA ==> ${trigger}");
                    });
                  },
                  name: "_",
                  options: ["Motivasi By All User", "Motivasi By User"]
                      .map((e) =>
                          FormBuilderFieldOption(value: e, child: Text("${e}")))
                      .toList()),
            ],
          ),
        )),
      ),
    );
  }
}
