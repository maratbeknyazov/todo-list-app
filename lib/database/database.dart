// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Этот файл - БАЗА ДАННЫХ приложения. Пишется в самом начале, до UI и логики.
//
// Что здесь происходит:
// - Создание локальной SQLite базы данных для хранения задач
// - Определение структуры таблицы TodoList (какие поля, какие типы)
// - CRUD операции: Create (создать), Read (прочитать), Update (обновить), Delete (удалить)
// - Миграции базы данных (onUpgrade) - когда нужно добавить новые поля
//
// Порядок написания:
// 1. Сначала пишем model/json (что такое "задача")
// 2. Потом database (как сохранять эту "задачу")
// 3. Потом logic (как менять данные)
// 4. И только в конце UI (как показывать)
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/utils/shared_util.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, "todo.db");
    return await openDatabase(
      path,
      version: 4,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        print("Текущая версия:$version");
        await db.execute("CREATE TABLE TodoList ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "account TEXT,"
            "taskName TEXT,"
            "taskType TEXT,"
            "taskStatus INTEGER,"
            "taskDetailNum INTEGER,"
            "uniqueId TEXT,"
            "needUpdateToCloud TEXT,"
            "overallProgress TEXT,"
            "changeTimes INTEGER,"
            "createDate TEXT,"
            "finishDate TEXT,"
            "startDate TEXT,"
            "deadLine TEXT,"
            "detailList TEXT,"
            "taskIconBean TEXT,"
            "textColor TEXT,"
            "backgroundUrl TEXT"
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        print("Новая версия:$newVersion");
        print("Старая версия:$oldVersion");
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE TodoList ADD COLUMN changeTimes INTEGER DEFAULT 0");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE TodoList ADD COLUMN uniqueId TEXT");
          await db.execute(
              "ALTER TABLE TodoList ADD COLUMN needUpdateToCloud TEXT");
        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE TodoList ADD COLUMN textColor TEXT");
          await db
              .execute("ALTER TABLE TodoList ADD COLUMN backgroundUrl TEXT");
        }
      },
    );

    /// Внимание: при создании таблицы последняя строка не должна содержать запятую
  }

  /// Создать задачу
  Future createTask(TaskBean task) async {
    final db = await database;
    task.id = await db.insert("TodoList", task.toMap());
  }

  /// Запросить все задачи по статусу выполнения
  ///
  /// isDone=true означает запрос завершенных задач, иначе незавершенных
  Future<List<TaskBean>> getTasks(
      {bool isDone = false, String? account}) async {
    final db = await database;
    final theAccount =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ?" +
            (isDone ? " AND overallProgress >= ?" : " AND overallProgress < ?"),
        whereArgs: [account ?? theAccount, "1.0"]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }

  /// Запросить все задачи
  Future<List<TaskBean>> getAllTasks({String? account}) async {
    final db = await database;
    final theAccount =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ?", whereArgs: [account ?? theAccount]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }

  Future updateTask(TaskBean? taskBean) async {
    if (taskBean == null) return;
    final db = await database;
    await db.update("TodoList", taskBean.toMap(),
        where: "id = ?", whereArgs: [taskBean.id]);
    debugPrint("Обновление текущей задачи:${taskBean.toMap()}");
  }

  Future deleteTask(int id) async {
    final db = await database;
    db.delete("TodoList", where: "id = ?", whereArgs: [id]);
  }

  /// Массовое обновление задач
  Future updateTasks(List<TaskBean> taskBeans) async {
    final db = await database;
    final batch = db.batch();
    for (var task in taskBeans) {
      batch.update("TodoList", task.toMap(),
          where: "id = ?", whereArgs: [task.id]);
    }
    final results = await batch.commit();
    print("Результат массового обновления:$results");
  }

  /// Массовое создание задач
  Future createTasks(List<TaskBean> taskBeans) async {
    final db = await database;
    final batch = db.batch();
    for (var task in taskBeans) {
      batch.insert("TodoList", task.toMap());
    }
    final results = await batch.commit();
    print("Результат массовой вставки:$results");
  }

  /// Запросить задачу по [uniqueId]
  Future<List<TaskBean>?> getTaskByUniqueId(String uniqueId) async {
    final db = await database;
    var tasks = await db
        .query("TodoList", where: "uniqueId = ?", whereArgs: [uniqueId]);
    if (tasks.isEmpty) return null;
    return TaskBean.fromMapList(tasks);
  }

  /// Массовое обновление аккаунта
  Future updateAccount(String account) async {
    final tasks = await getAllTasks(account: "default");
    List<TaskBean> newTasks = [];
    for (var task in tasks) {
      if (task.account == "default") {
        task.account = account;
        newTasks.add(task);
      }
    }
    print("Результат обновления:$newTasks   Исходные:$tasks");
    updateTasks(newTasks);
  }

  /// Нечеткий поиск с использованием символа процента
  Future<List<TaskBean>> queryTask(String query) async {
    final db = await database;
    final account =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    var list = await db.query("TodoList",
        where: "account = ? AND (taskName LIKE ? "
            "OR detailList LIKE ? "
            "OR startDate LIKE ? "
            "OR deadLine LIKE ?)",
        whereArgs: [
          account,
          "%$query%",
          "%$query%",
          "%$query%",
          "%$query%",
        ]);
    List<TaskBean> beans = [];
    beans.clear();
    beans.addAll(TaskBean.fromMapList(list));
    return beans;
  }
}
