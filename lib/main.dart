import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'dialog.dart';
import 'utils.dart';
import 'adminGroup.dart';
import 'json_controller.dart';

ListGroup groups;

void initJsons() {}

main() async {
  groups = ListGroup();
  List<Map<String, dynamic>> dataDecoded = [];
  await getApplicationDocumentsDirectory().then((dir) {
    List<FileSystemEntity> lista = dir.listSync();
    lista.removeWhere((item) {
      String path = item.path;
      return path.length <= 5 || path.substring(path.length - 5) != '.json';
    });
    lista.forEach((item) {
      dataDecoded.add(readData(item.path));
    });
    dataDecoded.sort((a, b) {
      return a['#-NameOfFile'].compareTo(b['#-NameOfFile']);
    });

    dataDecoded.forEach((item) {
      List<Student> auxStudents = [];
      Map<String, dynamic> auxMapa = item['alumnos'];
      auxMapa.forEach((k, v) {
        auxStudents.add(
            Student(k, v['nombre'], v['asistencia'] == 'true' ? true : false));
      });
      groups.value.add(Group(item['groupName'], auxStudents));
    });
  });
  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setNavigationBarColor(Colors.grey.shade50);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appttendance',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Mis Grupos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff075e55),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: groups.value.map((g) {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (a, b, c) {
                                return AdminGroup(
                                  groupName: g.id,
                                  students: g.students,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 400),
                              transitionsBuilder: (a, b, c, d) =>
                                  FadeTransition(opacity: b, child: d)));
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 500,
                      height: 500,
                      child: Center(
                        child: Text(
                          g.id,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (a, b, c) {
                    return CreateGroup();
                  },
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder: (a, b, c, d) =>
                      FadeTransition(opacity: b, child: d)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

StudentList _studentList = StudentList();

TextEditingController groupName = TextEditingController();
TextEditingController inputId = TextEditingController();
TextEditingController inputName = TextEditingController();

class CreateGroup extends StatefulWidget {
  @override
  CreateGroupState createState() => CreateGroupState();
}

class CreateGroupState extends State<CreateGroup> {
  BottomMenu _bottomMenu;
  List<Widget> componentes;

  @override
  void initState() {
    _bottomMenu = BottomMenu();
    super.initState();
  }

  void notifyDatachange() {
    if (mounted) setState(() {});
  }

  void clearParams() {
    _studentList.value.clear();
    groupName.text = "";
    clearText();
  }

  void clearText() {
    inputId.text = "";
    inputName.text = "";
  }

  void addGroup() {
    groups.value.add(Group(groupName.text, _studentList.value.toList()));
    Map<String, dynamic> mapa = {};
    mapa['groupName'] = groupName.text;
    mapa['alumnos'] = {};
    _studentList.value.forEach((s) {
      mapa['alumnos']
          [s.id] = {'nombre': s.name, 'asistencia': s.itshere.toString()};
    });
    saveJsonData(mapa, groupName.text);
  }

  void addStudent(String id, String name) {
    _studentList.value.add(Student(id, name, false));
  }

  @override
  Widget build(BuildContext context) {
    componentes = [];
    componentes.add(Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _studentList.value
            .map((s) {
              return Card(
                margin: EdgeInsets.fromLTRB(0, 7, 0, 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              s.name,
                              style: TextStyle(fontSize: 20),
                            ),
                            Container(
                              height: 10,
                            ),
                            Text(
                              s.id,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: RaisedButton(
                        color: Colors.red,
                        onPressed: () {
                          _studentList.value.remove(s);
                          notifyDatachange();
                        },
                        child: new Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        shape: new CircleBorder(),
                        // elevation: 4.0,
                      ),
                    )
                  ],
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    ));
    componentes.add(
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'GRUPO',
              ),
              controller: groupName,
            ),
            Container(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'MATRICULA',
              ),
              controller: inputId,
            ),
            Container(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'NOMBRE',
              ),
              controller: inputName,
            ),
            Container(
              height: 10,
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 10, bottom: 10
                    // left: 30,
                    // right: 30,
                    ),
                child: RaisedButton(
                  padding: EdgeInsets.all(13),
                  // shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(0)),
                  color: Color(0xff00799E),
                  child: Text(
                    'Agregar Alumno',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _studentList.value
                        .add(Student(inputId.text, inputName.text, false));
                    clearText();
                    setState(() {});
                  },
                )),
          ],
        ),
      ),
    );

    componentes = componentes.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff075e55),
        centerTitle: false,
        title: Text('Nuevo Grupo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.loop),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          clearParams();
                          notifyDatachange();
                          Navigator.pop(context);
                        },
                        textColor: Colors.red,
                        child: Text('Aceptar'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar'),
                      )
                    ],
                    titlePadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    title: Text(
                      '¿Limpiar todo?',
                      textAlign: TextAlign.center,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                    content: Text(
                      'Se restableceran los campos a su valor inicial',
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  titlePadding:
                                      EdgeInsets.fromLTRB(10, 20, 10, 10),
                                  title: Text(
                                    'Importando Alumnos',
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircularProgressIndicator()
                                    ],
                                  ),
                                );
                              });
                          await HttpClient()
                              .getUrl(Uri.parse(
                                  'http://www.xhonane.com/castor/grupos.txt'))
                              .then((HttpClientRequest request) =>
                                  request.close())
                              .then((HttpClientResponse response) =>
                                  response.transform(Utf8Decoder()).listen((s) {
                                    List<String> lines = s.split('\n');
                                    lines.forEach((line) {
                                      List<String> student = line.split(',');
                                      addStudent(student[0], student[1]);
                                    });
                                  }))
                              .whenComplete(() {
                            notifyDatachange();
                            Navigator.pop(context);
                            Timer(Duration(milliseconds: 300), () {
                              Navigator.pop(context);
                            });
                          });
                        },
                        textColor: Colors.red,
                        child: Text('Aceptar'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar'),
                      )
                    ],
                    titlePadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    title: Text(
                      '¿Importar alumnos?',
                      textAlign: TextAlign.center,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                    content: Text(
                      'Alumnos importados desde: \"www.xhonane.com/castor/grupos.txt\"\n\nPara gestionar este archivo favor de dirigirse a la página: \"www.xhonane.com/castor\"',
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (groupName.text.isNotEmpty) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            addGroup();
                            clearParams();
                            notifyDatachange();
                            Navigator.pop(context);
                          },
                          textColor: Colors.red,
                          child: Text('Aceptar'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancelar'),
                        )
                      ],
                      titlePadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      title: Text(
                        '¿Agregar grupo \"' + groupName.text + '\"?',
                        textAlign: TextAlign.center,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                      content: Text(
                        'No podrá realizar cambios despues de su creación',
                      ),
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('¡Advertencia!'),
                      content: Text('Es requerido establecer el nombre del grupo'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Ok'),
                        )
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: componentes),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.menu),
      //   onPressed: () {
      //     _bottomMenu.cloudPageBottomSheet(
      //         context, notifyDatachange, clearParams, addGroup, addStudent);
      //   },
      // ),
    );
  }
}
