import 'package:flutter/material.dart';
import 'package:sqflite_stream/screens/details_screen.dart';
import 'package:sqflite_stream/utils/bloc.dart';
import 'package:sqflite_stream/utils/model.dart';
import 'package:sqflite_stream/widgets/member_llst_widget.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen>
    with SingleTickerProviderStateMixin {
  MemberBloc _memberBloc = MemberBloc();

  AnimationController _animationController;
  Animation _scaleAnimation;
  double _opacity = 1;
  double _animatedOpacity = 0;

  @override
  void initState() {
    super.initState();
    _memberBloc.createInstance();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(microseconds: 10),
    );
    _scaleAnimation =
        Tween<double>(begin: 1, end: 30).animate(_animationController)
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DetailsScreen(Member(), _memberBloc)));
              _opacity = _animatedOpacity = 1;
              _animationController.reverse();
            }
          });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animatedOpacity = 1;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _memberBloc.memberStateStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error!'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!(snapshot.hasData)) {
              return Center(child: Text('Press the + button to add a member'));
            } else if (snapshot.hasData) {
              return snapshot.data.isEmpty
                  ? Center(child: Text('Press the + button to add a member'))
                  : Container(
                      width: double.infinity,
                      child: MemberListWidget(
                        memberBloc: _memberBloc,
                        snapshot: snapshot,
                      ),
                    );
            } else {
              return Center(child: Text('Unknown Error'));
            }
          },
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _animatedOpacity,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.withOpacity(.5)])),
              child: FlatButton(
                color: Colors.transparent,
                shape: CircleBorder(),
                onPressed: () {
                  _opacity = 0;
                  _animationController.forward();
                },
                child: Opacity(
                  opacity: _opacity,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _memberBloc.dispose();
    _animationController.dispose();
  }
}
