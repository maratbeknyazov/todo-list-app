


///Тип заголовка боковой панели: метеорный поток, ежедневные обои, сетевое изображение
class NavHeadType{
  static const String meteorShower = "MeteorShower";
  static const String dailyPic = "DailyPic";
  static const String netPicture = "NetPicture";


  ///Адрес изображения ежедневных обоев
  static const String DAILY_PIC_URL =  "https://source.unsplash.com/random/300x200";
}


///Назначение изображения на странице сетевых изображений
class NetPicturesUseType{
  ///Используется как фон страницы "Мой аккаунт"
  static const String accountBackground = "account_background";

  ///Используется как заголовок боковой панели
  static const String navigatorHeader = NavHeadType.netPicture;

  ///Используется как фон главной страницы
  static const String mainPageBackground = "main_page_background";

  ///Используется как фон карточки задачи
  static const String taskCardBackground = "task_card_background";
}

///Тип фона страницы "Мой аккаунт"
class AccountBGType{
  static const String defaultType = "default_account_background_type";
  static const String netPicture = "net_account_picture_type";

}