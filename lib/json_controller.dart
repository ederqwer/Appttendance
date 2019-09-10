import 'dart:io';
import 'dart:convert';

///[ELIMINAR]
import 'package:path_provider/path_provider.dart';

void saveJsonData(Map<String, dynamic> data, String fileName) {
  getApplicationDocumentsDirectory().then((dir) {
    DateTime dt = DateTime.now();
    data['#-NameOfFile'] = fileName;
    data['#-dateofFile'] = parseFormat(dt.day) +
        '/' +
        parseFormat(dt.month) +
        '/' +
        parseFormat(dt.year);
    data['#-timeofFile'] = parseFormat(dt.hour) + ':' + parseFormat(dt.minute);
    File file = new File(dir.path + "/CLFile_" + fileName + '.json');
    file.writeAsStringSync(jsonEncode(data));
  });
}

String parseFormat(int time) {
  switch (time) {
    case 0:
      return "00";
    case 1:
      return "01";
    case 2:
      return "02";
    case 3:
      return "03";
    case 4:
      return "04";
    case 5:
      return "05";
    case 6:
      return "06";
    case 7:
      return "07";
    case 8:
      return "08";
    case 9:
      return "09";
  }
  return time.toString();
}

Map<String, dynamic> readData(String path) {
    File file = new File(path);
    String content = file.readAsStringSync();
    return jsonDecode(content);
}
