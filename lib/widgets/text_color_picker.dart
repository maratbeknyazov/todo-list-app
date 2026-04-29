import 'package:flutter/material.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextColorPicker extends StatefulWidget {

  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const TextColorPicker({super.key, required this.initialColor, required this.onColorChanged});

  @override
  _TextColorPickerState createState() => _TextColorPickerState();
}

class _TextColorPickerState extends State<TextColorPicker> {


  Color defaultColor = Colors.black;

  @override
  void initState() {
    defaultColor = widget.initialColor;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      elevation: 0.0,
      title: Text(IntlLocalizations.of(context).pickAColor),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: defaultColor,
          onColorChanged: (color) {
            defaultColor = color;
          },
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            IntlLocalizations.of(context).cancel,
            style: TextStyle(color: Colors.redAccent),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(IntlLocalizations.of(context).ok),
          onPressed: () {
            widget.onColorChanged(defaultColor);
            setState(() {});
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
