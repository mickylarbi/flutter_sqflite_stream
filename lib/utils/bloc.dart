import 'dart:async';

import 'package:sqflite_stream/utils/database_helper.dart';
import 'package:sqflite_stream/utils/model.dart';

abstract class MemberEvent {
  Member member;
  MemberEvent(this.member);
}

class MemberInsertEvent extends MemberEvent {
  Member _member;
  MemberInsertEvent(this._member) : super(_member);
}

class MemberUpdateEvent extends MemberEvent {
  Member _member;
  MemberUpdateEvent(this._member) : super(_member);
}

class MemberDeleteEvent extends MemberEvent {
  Member _member;
  MemberDeleteEvent(this._member) : super(_member);
}

class MemberBloc {
  DatabaseHelper databaseHelper;
  List<Member> _memberList;

  final _memberEventController = StreamController<MemberEvent>();
  final _memberStateController = StreamController<List<Member>>();

  StreamSink<MemberEvent> get memberEventSink => _memberEventController.sink;
  StreamSink<List<Member>> get _memberStateSink => _memberStateController.sink;
  Stream get memberStateStream => _memberStateController.stream;

  createInstance() async {
    databaseHelper = DatabaseHelper();
    _memberList = await databaseHelper.members();
    _memberStateSink.add(_memberList);

    _memberEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(MemberEvent memberEvent) async {
    if (memberEvent is MemberInsertEvent) {
      await databaseHelper.insertMember(memberEvent._member);
    } else if (memberEvent is MemberUpdateEvent) {
      await databaseHelper.updateMember(memberEvent._member);
    } else if (memberEvent is MemberDeleteEvent) {
      await databaseHelper.deleteMember(memberEvent._member);
    }

    _memberList = await databaseHelper.members();
    _memberStateSink.add(_memberList);
  }

  void dispose() {
    _memberEventController.close();
    _memberStateController.close();
  }
}
