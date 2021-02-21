import 'package:flutter/material.dart';
import 'package:sqflite_stream/screens/details_screen.dart';
import 'package:sqflite_stream/utils/bloc.dart';
import 'package:sqflite_stream/utils/model.dart';

class MemberListWidget extends StatelessWidget {
  MemberListWidget({
    Key key,
    @required MemberBloc memberBloc,
    @required AsyncSnapshot snapshot,
  })  : _memberBloc = memberBloc,
        _snapshot = snapshot,
        super(key: key);

  final MemberBloc _memberBloc;
  final AsyncSnapshot _snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14),
      itemCount: _snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        Member _member = _snapshot.data[index];
        return ListTile(
          title: Text(_member.name),
          subtitle: Text('${_member.age}'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _memberBloc.memberEventSink.add(MemberDeleteEvent(_member));
            },
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DetailsScreen(_member, _memberBloc)));
          },
        );
      },
    );
  }
}
