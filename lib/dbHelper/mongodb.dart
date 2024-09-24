import 'dart:developer';

import 'package:flutter_mongodb_crud_midexam/MongoDBModel.dart';
import 'package:flutter_mongodb_crud_midexam/dbHelper/constrant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db, userCollection;
  static connect() async {
    db = await Db.create(MONG_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final arrData = await userCollection.find().toList();
    return arrData;
  }

  static Future<void> update(MongoDbModel oldData, MongoDbModel newData) async {
    await userCollection.update(
      where.eq("taskName", oldData.taskName),
      modify
          .set("taskName", newData.taskName)
          .set("time", newData.time)
          .set("priority", newData.priority),
    );
  }

  static delete(MongoDbModel user) async {
    await userCollection.remove(where.eq('taskName', user.taskName));
  }

  static Future<String> insert(MongoDbModel data) async {
    try {
      var result = await userCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data inserted";
      } else {
        return "Something is wrong while insert data";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
