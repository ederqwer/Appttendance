import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'custom_button_component.dart';

class BottomMenu {
  cloudPageBottomSheet(BuildContext context, Function notify, Function clear,
      Function addGroup, Function addStudent) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(

              ///[Grey background modal 0xFF737373]
              color: Color(0xFF737373),
              height: 200,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 25),
                          child: Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 9,
                          runSpacing: 4.0,
                          children: <Widget>[
                            CustomButtonComponent(
                              context: context,
                              label: 'Borrar Todo',
                              icon: Icons.delete,
                              onPressed: () {
                                clear();
                                notify();
                                Navigator.pop(context);
                              },
                            ),
                            CustomButtonComponent(
                              context: context,
                              label: 'Crear Grupo',
                              icon: Icons.group,
                              onPressed: () {
                                addGroup();
                                clear();
                                notify();
                                Navigator.pop(context);
                              },
                            ),
                            CustomButtonComponent(
                              context: context,
                              label: 'Importar Estudiantes',
                              icon: Icons.cloud,
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
                                        response
                                            .transform(Utf8Decoder())
                                            .listen((s) {
                                          List<String> lines = s.split('\n');
                                          lines.forEach((line) {
                                            List<String> student =
                                                line.split(',');
                                            addStudent(student[0], student[1]);
                                          });
                                        })).whenComplete((){
                                          Navigator.pop(context);
                                        });
                                notify();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                      ])));
        });
  }
}
