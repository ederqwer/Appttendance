class Group {
  String id;
  List<Student> students;
  Group(this.id, this.students);
}

class ListGroup {
  List<Group> value = [];
}

class Student {
  String id;
  String name;
  bool itshere;
  Student(this.id, this.name, this.itshere);
}

class StudentList {
  List<Student> value = [];
}