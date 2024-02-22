
class Student {
  String name;
  String surname;
  String faculty;
  String department;

  // Constructor
  Student({required this.name, required this.surname, required this.faculty, required this.department});

  // Factory method to create a Student object from a Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['Name'] ?? '',
      surname: map['Surname'] ?? '',
      faculty: map['Faculty'] ?? '',
      department: map['Department'] ?? '',
    );
  }
}