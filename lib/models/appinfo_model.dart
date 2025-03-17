// To parse this JSON data, do
//
//     final appInfo = appInfoFromJson(jsonString);

import 'dart:convert';

AppInfo appInfoFromJson(String str) => AppInfo.fromJson(json.decode(str));

String appInfoToJson(AppInfo data) => json.encode(data.toJson());

class AppInfo {
  final List<Line>? lines;
  final List<Value>? values;
  final List<String>? operators;

  AppInfo({
    this.lines,
    this.values,
    this.operators,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        lines: json["lines"] == null
            ? []
            : List<Line>.from(json["lines"]!.map((x) => Line.fromJson(x))),
        values: json["values"] == null
            ? []
            : List<Value>.from(json["values"]!.map((x) => Value.fromJson(x))),
        operators: json["operators"] == null
            ? []
            : List<String>.from(json["operators"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "lines": lines == null
            ? []
            : List<dynamic>.from(lines!.map((x) => x.toJson())),
        "values": values == null
            ? []
            : List<dynamic>.from(values!.map((x) => x.toJson())),
        "operators": operators == null
            ? []
            : List<dynamic>.from(operators!.map((x) => x)),
      };
}

class Line {
  final String? appId;
  final String? lineId;
  final String? name;
  final int? frequency;
  final int? window;
  final DateTime? lastExecuted;
  final bool? closed;
  final bool? status;
  final List<Unit>? units;

  Line({
    this.appId,
    this.lineId,
    this.name,
    this.frequency,
    this.window,
    this.lastExecuted,
    this.closed,
    this.status,
    this.units,
  });

  factory Line.fromJson(Map<String, dynamic> json) => Line(
        appId: json["appId"],
        lineId: json["lineId"],
        name: json["name"],
        frequency: json["frequency"],
        window: json["window"],
        lastExecuted: json["lastExecuted"] == null
            ? null
            : DateTime.parse(json["lastExecuted"]),
        closed: json["closed"],
        status: json["status"],
        units: json["units"] == null
            ? []
            : List<Unit>.from(json["units"]!.map((x) => Unit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "appId": appId,
        "lineId": lineId,
        "name": name,
        "frequency": frequency,
        "window": window,
        "lastExecuted": lastExecuted?.toIso8601String(),
        "closed": closed,
        "status": status,
        "units": units == null
            ? []
            : List<dynamic>.from(units!.map((x) => x.toJson())),
      };
}

class Unit {
  final String? appId;
  final String? unitId;
  final String? name;

  Unit({
    this.appId,
    this.unitId,
    this.name,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        appId: json["appId"],
        unitId: json["unitId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "appId": appId,
        "unitId": unitId,
        "name": name,
      };
}

class Value {
  final String? appId;
  final String? id;
  final dynamic parentId;
  final bool? isInspection;
  final String? name;

  Value({
    this.appId,
    this.id,
    this.parentId,
    this.isInspection,
    this.name,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        appId: json["appId"],
        id: json["id"],
        parentId: json["parentId"],
        isInspection: json["isInspection"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "appId": appId,
        "id": id,
        "parentId": parentId,
        "isInspection": isInspection,
        "name": name,
      };
}
