class Member {
  int _id;
  String _name;
  int _age;

  Member([this._name, this._age, this._id]);

  int get id => _id;
  String get name => _name;
  int get age => _age;

  set id(id) => _id = id;
  set name(name) => _name = name;
  set age(age) => _age = age;

  Map<String, dynamic> toMap() => {'id': _id, 'name': _name, 'age': _age};

  Member.fromMap(Map map) {
    _id = map['id'];
    _name = map['name'];
    _age = map['age'];
  }
}
