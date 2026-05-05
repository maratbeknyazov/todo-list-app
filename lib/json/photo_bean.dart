// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель фотографии из API Unsplash (сервис бесплатных изображений)
// Используется для фоновых изображений в приложении
// ============================================================================

class PhotoBean {
  /*
   * id : "aH8tRjQG4XM"
   * created_at : "2019-07-18T06:20:04-04:00"
   * updated_at : "2019-07-18T06:55:09-04:00"
   * color : "#C68E7A"
   * sponsored : false
   * liked_by_user : false
   * width : 2254
   * height : 2817
   * likes : 35
   * links : {"self":"https://api.unsplash.com/photos/aH8tRjQG4XM","html":"https://unsplash.com/photos/aH8tRjQG4XM","download":"https://unsplash.com/photos/aH8tRjQG4XM/download","download_location":"https://api.unsplash.com/photos/aH8tRjQG4XM/download"}
   * urls : {"raw":"https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjgxNjY3fQ","full":"https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjgxNjY3fQ","regular":"https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ","small":"https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ","thumb":"https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ"}
   * user : {"id":"hHQGJB9ZejE","updated_at":"2019-07-18T07:57:50-04:00","username":"rotaalternativa","name":"Rota Alternativa","first_name":"Rota","last_name":"Alternativa","twitter_username":null,"portfolio_url":"https://www.instagram.com/rotaalternativarv/","bio":"We are exploring the nomad and simple life the road has to offer. Living in our 1992 Fiat Talento motorhome.","location":null,"links":{"self":"https://api.unsplash.com/users/rotaalternativa","html":"https://unsplash.com/@rotaalternativa","photos":"https://api.unsplash.com/users/rotaalternativa/photos","likes":"https://api.unsplash.com/users/rotaalternativa/likes","portfolio":"https://api.unsplash.com/users/rotaalternativa/portfolio","following":"https://api.unsplash.com/users/rotaalternativa/following","followers":"https://api.unsplash.com/users/rotaalternativa/followers"},"profile_image":{"small":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32","medium":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64","large":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128"},"instagram_username":"rotaalternativarv","total_collections":0,"total_likes":1,"total_photos":72,"accepted_tos":true}
   */

  late String id;
  late String createdAt;
  late String updatedAt;
  late String color;
  late bool sponsored;
  late bool likedByUser;
  late int width;
  late int height;
  late int likes;
  late LinksBean links;
  late UrlsBean urls;

  static PhotoBean fromMap(Map<String, dynamic> map) {
    PhotoBean photoBean = new PhotoBean();
    photoBean.id = map['id'] as String? ?? '';
    photoBean.createdAt = map['created_at'] as String? ?? '';
    photoBean.updatedAt = map['updated_at'] as String? ?? '';
    photoBean.color = map['color'] as String? ?? '';
    photoBean.sponsored = map['sponsored'] as bool? ?? false;
    photoBean.likedByUser = map['liked_by_user'] as bool? ?? false;
    photoBean.width = map['width'] as int? ?? 0;
    photoBean.height = map['height'] as int? ?? 0;
    photoBean.likes = map['likes'] as int? ?? 0;
    photoBean.links = map['links'] != null
        ? LinksBean.fromMap(map['links'] as Map<String, dynamic>)
        : LinksBean.fromMap({});
    photoBean.urls = map['urls'] != null
        ? UrlsBean.fromMap(map['urls'] as Map<String, dynamic>)
        : UrlsBean.fromMap({});
    return photoBean;
  }

  Map<String, dynamic> tpMap() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'color': color,
      'sponsored': sponsored,
      'liked_by_user': likedByUser,
      'width': width,
      'height': height,
      'likes': likes,
      'links': links.toMap(),
      'urls': urls.toMap()
    };
  }

  static List<PhotoBean> fromMapList(dynamic mapList) {
    List<PhotoBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }
}

class LinksBean {
  /*
   * self : "https://api.unsplash.com/users/rotaalternativa"
   * html : "https://unsplash.com/@rotaalternativa"
   * photos : "https://api.unsplash.com/users/rotaalternativa/photos"
   * likes : "https://api.unsplash.com/users/rotaalternativa/likes"
   * portfolio : "https://api.unsplash.com/users/rotaalternativa/portfolio"
   * following : "https://api.unsplash.com/users/rotaalternativa/following"
   * followers : "https://api.unsplash.com/users/rotaalternativa/followers"
   */

  late String self;
  late String html;
  late String photos;
  late String likes;
  late String portfolio;
  late String following;
  late String followers;

  static LinksBean fromMap(Map<String, dynamic> map) {
    LinksBean linksBean = new LinksBean();
    linksBean.self = map['self'] as String? ?? '';
    linksBean.html = map['html'] as String? ?? '';
    linksBean.photos = map['photos'] as String? ?? '';
    linksBean.likes = map['likes'] as String? ?? '';
    linksBean.portfolio = map['portfolio'] as String? ?? '';
    linksBean.following = map['following'] as String? ?? '';
    linksBean.followers = map['followers'] as String? ?? '';
    return linksBean;
  }

  static List<LinksBean> fromMapList(dynamic mapList) {
    List<LinksBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'self': self,
      'html': html,
      'photos': photos,
      'likes': likes,
      'portfolio': portfolio,
      'following': following,
      'followers': followers
    };
  }
}

class UrlsBean {
  /*
   * raw : "https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjgxNjY3fQ"
   * full : "https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjgxNjY3fQ"
   * regular : "https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ"
   * small : "https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ"
   * thumb : "https://images.unsplash.com/photo-1563445192071-fb5b2fa4ad62?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&ixid=eyJhcHBfaWQiOjgxNjY3fQ"
   */

  late String raw;
  late String full;
  late String regular;
  late String small;
  late String thumb;

  static UrlsBean fromMap(Map<String, dynamic> map) {
    UrlsBean urlsBean = new UrlsBean();
    urlsBean.raw = map['raw'] as String? ?? '';
    urlsBean.full = map['full'] as String? ?? '';
    urlsBean.regular = map['regular'] as String? ?? '';
    urlsBean.small = map['small'] as String? ?? '';
    urlsBean.thumb = map['thumb'] as String? ?? '';
    return urlsBean;
  }

  static List<UrlsBean> fromMapList(dynamic mapList) {
    List<UrlsBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'raw': raw,
      'full': full,
      'regular': regular,
      'small': small,
      'thumb': thumb
    };
  }
}

class UserBean {
  /*
   * id : "hHQGJB9ZejE"
   * updated_at : "2019-07-18T07:57:50-04:00"
   * username : "rotaalternativa"
   * name : "Rota Alternativa"
   * first_name : "Rota"
   * last_name : "Alternativa"
   * portfolio_url : "https://www.instagram.com/rotaalternativarv/"
   * bio : "We are exploring the nomad and simple life the road has to offer. Living in our 1992 Fiat Talento motorhome."
   * instagram_username : "rotaalternativarv"
   * accepted_tos : true
   * total_collections : 0
   * total_likes : 1
   * total_photos : 72
   * links : {"self":"https://api.unsplash.com/users/rotaalternativa","html":"https://unsplash.com/@rotaalternativa","photos":"https://api.unsplash.com/users/rotaalternativa/photos","likes":"https://api.unsplash.com/users/rotaalternativa/likes","portfolio":"https://api.unsplash.com/users/rotaalternativa/portfolio","following":"https://api.unsplash.com/users/rotaalternativa/following","followers":"https://api.unsplash.com/users/rotaalternativa/followers"}
   * profile_image : {"small":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32","medium":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64","large":"https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128"}
   */

  late String id;
  late String updatedAt;
  late String username;
  late String name;
  late String firstName;
  late String lastName;
  late String portfolioUrl;
  late String bio;
  late String instagramUsername;
  late bool acceptedTos;
  late int totalCollections;
  late int totalLikes;
  late int totalPhotos;
  late LinksBean links;
  late ProfileImageBean profileImage;

  static UserBean fromMap(Map<String, dynamic> map) {
    UserBean userBean = new UserBean();
    userBean.id = map['id'] as String? ?? '';
    userBean.updatedAt = map['updated_at'] as String? ?? '';
    userBean.username = map['username'] as String? ?? '';
    userBean.name = map['name'] as String? ?? '';
    userBean.firstName = map['first_name'] as String? ?? '';
    userBean.lastName = map['last_name'] as String? ?? '';
    userBean.portfolioUrl = map['portfolio_url'] as String? ?? '';
    userBean.bio = map['bio'] as String? ?? '';
    userBean.instagramUsername = map['instagram_username'] as String? ?? '';
    userBean.acceptedTos = map['accepted_tos'] as bool? ?? false;
    userBean.totalCollections = map['total_collections'] as int? ?? 0;
    userBean.totalLikes = map['total_likes'] as int? ?? 0;
    userBean.totalPhotos = map['total_photos'] as int? ?? 0;
    userBean.links = map['links'] != null
        ? LinksBean.fromMap(map['links'] as Map<String, dynamic>)
        : LinksBean.fromMap({});
    userBean.profileImage = map['profile_image'] != null
        ? ProfileImageBean.fromMap(map['profile_image'] as Map<String, dynamic>)
        : ProfileImageBean.fromMap({});
    return userBean;
  }

  static List<UserBean> fromMapList(dynamic mapList) {
    List<UserBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }
}

class ProfileImageBean {
  /*
   * small : "https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32"
   * medium : "https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64"
   * large : "https://images.unsplash.com/profile-1550700203074-81551f41d6fe?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128"
   */

  late String small;
  late String medium;
  late String large;

  static ProfileImageBean fromMap(Map<String, dynamic> map) {
    ProfileImageBean profileImageBean = new ProfileImageBean();
    profileImageBean.small = map['small'] as String? ?? '';
    profileImageBean.medium = map['medium'] as String? ?? '';
    profileImageBean.large = map['large'] as String? ?? '';
    return profileImageBean;
  }

  static List<ProfileImageBean> fromMapList(dynamic mapList) {
    List<ProfileImageBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }
}
