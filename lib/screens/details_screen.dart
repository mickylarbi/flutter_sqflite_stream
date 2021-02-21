import 'package:flutter/material.dart';
import 'package:sqflite_stream/utils/bloc.dart';
import 'package:sqflite_stream/utils/model.dart';

class DetailsScreen extends StatefulWidget {
  Member _member;
  MemberBloc _memberBloc;
  DetailsScreen(this._member, this._memberBloc);
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;
  double _buttonOpacity = 1;
  AnimationController _animationController;
  Animation _buttonAnimation;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = widget._member.name;
    _ageController.text =
        widget._member.age == null ? '' : '${widget._member.age}';

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _buttonAnimation = Tween<double>(begin: 1, end: 100).animate(
        CurvedAnimation(curve: Curves.easeInQuad, parent: _animationController))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _opacity = 1;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _opacity,
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //name textbox-------------------------------
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(fontSize: 16, letterSpacing: .5),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 14),
                              hintText: 'Name goes here',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], letterSpacing: 1)),
                        ),
                      ),
                      SizedBox(height: 20),
                      //age textbox-------------------------------------
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 16, letterSpacing: .5),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 14),
                              hintText: 'Age goes here',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], letterSpacing: 1)),
                        ),
                      ),
                      SizedBox(height: 40),
                      //button---------------------------------------
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => Transform.scale(
                          scale: _buttonAnimation.value,
                          child: InkWell(
                            onTap: () {
                              if (_nameController.text.trim().isEmpty ||
                                  _ageController.text.trim().isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content:
                                        Text('One or more fields are empty'),
                                  ),
                                );
                              } else {
                                widget._member.name = _nameController.text;
                                try {
                                  widget._member.age =
                                      int.parse(_ageController.text.trim());

                                  _buttonOpacity = 0;
                                  _animationController.forward();

                                  if (widget._member.id == null) {
                                    widget._memberBloc.memberEventSink
                                        .add(MemberInsertEvent(widget._member));
                                  } else {
                                    widget._memberBloc.memberEventSink
                                        .add(MemberUpdateEvent(widget._member));
                                  }
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text('Enter a valid age'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Colors.blue.withOpacity(.5)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(0),
                              child: AnimatedOpacity(
                                duration: Duration(microseconds: 100),
                                opacity: _buttonOpacity,
                                child: Text(
                                  widget._member.id == null
                                      ? 'INSERT'
                                      : 'UPDATE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      letterSpacing: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
  }
}
