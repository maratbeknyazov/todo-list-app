// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// IconSettingPageModel - модель страницы выбора иконки для задачи
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/logic/all_logic.dart';

class IconSettingPageModel extends ChangeNotifier {
  late IconSettingPageLogic logic;
  BuildContext? context;

  /// Currently selected icon
  List<TaskIconBean> taskIcons = [];

  /// All icons displayed below the divider line
  List<IconBean> showIcons = [];

  /// All icons from search results
  List<IconBean> searchIcons = [];
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();


  Color currentPickerColor = Colors.black;
  String currentIconName = "";
  bool isDeleting = false;
  bool isSearching = false;

  IconSettingPageModel() {
    logic = IconSettingPageLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait([
        logic.getTaskIconList(),
        logic.getIconList(),
      ]).then((value) {
        refresh();
      });
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
    debugPrint("IconSettingPageModel destroyed");
  }

  void refresh() {
    notifyListeners();
  }
}
