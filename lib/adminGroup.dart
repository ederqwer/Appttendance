import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'utils.dart';
import 'json_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class AdminGroup extends StatefulWidget {
  final List<Student> students;
  final String groupName;
  const AdminGroup({Key key, this.students, this.groupName}) : super(key: key);
  @override
  AdminGroupState createState() => AdminGroupState();
}

class AdminGroupState extends State<AdminGroup> {
  void notifyData() {
    Map<String, dynamic> mapa = {};
    mapa['groupName'] = widget.groupName;
    mapa['alumnos'] = {};
    widget.students.forEach((s) {
      mapa['alumnos']
          [s.id] = {'nombre': s.name, 'asistencia': s.itshere.toString()};
    });
    saveJsonData(mapa, widget.groupName);
    if (mounted) setState(() {});
  }

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  bool showAll = true;

  void _startDiscovery() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Detener',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  _streamSubscription?.cancel();
                  Navigator.pop(context);
                },
              )
            ],
            titlePadding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            title: Text(
              'Buscando dispositivos',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[CircularProgressIndicator()],
            ),
          );
        }).whenComplete(() {
      stopScan();
    });
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      widget.students.forEach((s) {
        if (s.id == r.device.name) {
          s.itshere = true;
          notifyData();
        }
      });
    });
    _streamSubscription.onDone(() {
      Navigator.pop(context);
    });
  }

  void stopScan() {
    _streamSubscription?.cancel();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  Future _writeFile() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            title: Text(
              'Guardando',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[CircularProgressIndicator()],
            ),
          );
        });
    Directory directory;
    await getApplicationDocumentsDirectory().then((dir) {
      directory = dir;
    });
    DateTime dt = DateTime.now();
    String date = dt.toUtc().toString().split(' ')[0];
    File f = File(
        directory.path + '/Grupo ' + widget.groupName + ' ' + date + '.txt');
    String dataExport =
        'Grupo: ' + widget.groupName + ' Fecha: ' + date + '\n\n';
    widget.students.forEach((s) {
      dataExport += s.id +
          '\n' +
          s.name +
          '\nAsistencia: ' +
          (s.itshere.toString() == 'true' ? 'SI' : 'NO') +
          '\n\n';
    });
    await f.writeAsString(dataExport).whenComplete(() {
      Timer(Duration(seconds: 1), () {
        Navigator.pop(context);
        _shared();
      });
    });
    //
  }

  Future _shared() async {
    Directory directory;
    await getApplicationDocumentsDirectory().then((dir) {
      directory = dir;
    });
    DateTime dt = DateTime.now();
    String date = dt.toUtc().toString().split(' ')[0];
    ShareExtend.share(
        directory.path + '/Grupo ' + widget.groupName + ' ' + date + '.txt',
        "file");
    // File f = File(directory.path + '/export.txt');
  }

  @override
  Widget build(BuildContext context) {
    List<Student> auxStudents = widget.students.toList();
    if (!showAll) {
      auxStudents.removeWhere((s) {
        return s.itshere;
      });
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.loop),
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      widget.students.forEach((s) {
                        s.itshere = false;
                      });
                      notifyData();
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
                  '¿Reiniciar la asistencia?',
                  textAlign: TextAlign.center,
                ),
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                content: Text(
                  'Se perdera el estado actual de la asistencia de TODOS los alumnos del grupo',
                ),
              );
            },
          );
          
        },
      ),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _writeFile();
            },
          ),
          IconButton(
            icon: Icon(Icons.bluetooth_searching),
            onPressed: () {
              _startDiscovery();
            },
          ),
          IconButton(
            onPressed: () {
              showAll = !showAll;
              notifyData();
            },
            icon: Icon(showAll ? Icons.visibility : Icons.visibility_off),
          ),
        ],
        elevation: 0,
        backgroundColor: Color(0xff075e55),
        title: Text('Grupo ' + widget.groupName),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
        children: auxStudents.map((s) {
          return InkWell(
            onTap: () {
              s.itshere = !s.itshere;
              notifyData();
            },
            child: Container(
              // color: Colors.red,
              padding: EdgeInsets.only(top: 15, bottom: 0, left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: s.itshere ? Color(0xff37557C) : Color(0xffdfe5e7),
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      s.name,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      height: 10,
                                    ),
                                    Text(
                                      s.id,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                s.itshere
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: s.itshere ? Color(0xff37557C) : Color(0xffdfe5e7),
                              )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            // padding: EdgeInsets.all(0),
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
