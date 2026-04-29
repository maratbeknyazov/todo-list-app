import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/utils/shared_util.dart';

class LanguagePage extends StatelessWidget {
  final List<LanguageData> languageDatas = [
    LanguageData("中文", "zh", "CN", "一日"),
    LanguageData("English", "en", "US", "One Day"),
  ];

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(IntlLocalizations.of(context).languageTitle),
      ),
      body: Container(
        child: RadioGroup<String>(
          groupValue: model.currentLanguage,
          onChanged: (value) {
            final selectedData = languageDatas.firstWhere((data) => data.language == value);
            model.currentLanguageCode = [selectedData.languageCode, selectedData.countryCode];
            model.currentLanguage = selectedData.language;
            model.currentLocale = Locale(selectedData.languageCode, selectedData.countryCode);
            model.appName = selectedData.appName;
            model.refresh();
            SharedUtil.instance.saveStringList(
                Keys.currentLanguageCode, [selectedData.languageCode, selectedData.countryCode]);
            SharedUtil.instance.saveString(Keys.currentLanguage, selectedData.language);
            SharedUtil.instance.saveString(Keys.appName, selectedData.appName);
          },
          child: ListView(
            children: List.generate(languageDatas.length, (index) {
              final String language = languageDatas[index].language;
              return RadioListTile(
                value: language,
                title: Text(languageDatas[index].language),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class LanguageData {
  String language;
  String languageCode;
  String countryCode;
  String appName;

  LanguageData(
      this.language, this.languageCode, this.countryCode, this.appName);
}
