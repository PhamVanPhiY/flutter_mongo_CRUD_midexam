// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

MongoDbModel mongoDbModelFromJson(String str) =>
    MongoDbModel.fromJson(json.decode(str));

String mongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
  String taskName;
  String time;
  String priority;

  MongoDbModel({
    required this.taskName,
    required this.time,
    required this.priority,
  });

  factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
        taskName: json["taskName"],
        time: json["time"],
        priority: json["priority"],
      );

  Map<String, dynamic> toJson() => {
        "taskName": taskName,
        "time": time,
        "priority": priority,
      };
}
