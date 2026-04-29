import 'package:flutter/material.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import 'package:todo_list/i10n/localization_intl.dart';

class CustomTimePicker extends StatefulWidget {

  final ConfirmCallBack callBack;

  const CustomTimePicker({super.key, required this.callBack});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {

  int start = 0;
  int end = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        )),
        child: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  IntlLocalizations.of(context).selectLightTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(child: Text(IntlLocalizations.of(context).start,style: TextStyle(fontSize: 12),),margin: EdgeInsets.only(bottom: 18),),
                    Container(
                      child: getTimeWheel(true,context),
                      width: 50,
                    ),
                    Container(width: 50),
                    Container(child: Text(IntlLocalizations.of(context).end,style: TextStyle(fontSize: 12),),margin: EdgeInsets.only(bottom: 18),),
                    Container(
                      child: getTimeWheel(false,context),
                      width: 50,
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 2),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(IntlLocalizations.of(context).cancel)),
                    )),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 2),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if(start >= end){
                              showDialog(context: context, builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                content: Text(IntlLocalizations.of(context).timeError),
                              ),);
                              return;
                            }
                            widget.callBack(start,end);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            IntlLocalizations.of(context).ok,
                            style: TextStyle(color: Colors.white),
                          )),
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimeWheel(bool isAm, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: WheelChooser.integer(
        onValueChanged: (value) {
          if(isAm){
            start = value;
          } else {
            end = value;
          }
        },
        selectTextStyle: TextStyle(fontSize: 15,color: Theme.of(context).primaryColor),
        maxValue: 24,
        minValue: 0,
      ),
    );
  }
}

typedef ConfirmCallBack = Function(int start, int end);
