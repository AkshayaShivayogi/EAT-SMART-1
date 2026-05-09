import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Meal {
  final int? id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime time;
  final List<String> tags;
  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.time,
    required this.tags,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'time': time.millisecondsSinceEpoch,
      'tags': jsonEncode(tags),
    };
  }
  static Meal fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      tags: List<String>.from(jsonDecode(map['tags'] as String)),
    );
  }
}

class User {
  final int? id;
  final String name;
  final double weightKg;
  final double heightCm;
  final int age;
  User({this.id, required this.name, required this.weightKg, required this.heightCm, required this.age});
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'weightKg': weightKg, 'heightCm': heightCm, 'age': age};
  }
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      weightKg: (map['weightKg'] as num).toDouble(),
      heightCm: (map['heightCm'] as num).toDouble(),
      age: (map['age'] as num).toInt(),
    );
  }
}

class Condition {
  final int? id;
  final int userId;
  final String type;
  final String notes;
  final DateTime start;
  final DateTime? end;
  Condition({this.id, required this.userId, required this.type, required this.notes, required this.start, this.end});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'notes': notes,
      'start': start.millisecondsSinceEpoch,
      'end': end?.millisecondsSinceEpoch
    };
  }
  static Condition fromMap(Map<String, dynamic> map) {
    return Condition(
      id: map['id'] as int?,
      userId: (map['userId'] as num).toInt(),
      type: map['type'] as String,
      notes: map['notes'] as String,
      start: DateTime.fromMillisecondsSinceEpoch(map['start'] as int),
      end: map['end'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['end'] as int),
    );
  }
}

class DayPlan {
  final int? id;
  final int userId;
  final DateTime date;
  final List<String> items;
  final bool completed;
  DayPlan({this.id, required this.userId, required this.date, required this.items, required this.completed});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
      'items': jsonEncode(items),
      'completed': completed ? 1 : 0
    };
  }
  static DayPlan fromMap(Map<String, dynamic> map) {
    return DayPlan(
      id: map['id'] as int?,
      userId: (map['userId'] as num).toInt(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      items: List<String>.from(jsonDecode(map['items'] as String)),
      completed: (map['completed'] as num) == 1,
    );
  }
}

class Goal {
  final int? id;
  final String type;
  final double target;
  final String period;
  Goal({this.id, required this.type, required this.target, required this.period});
  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'target': target, 'period': period};
  }
  static Goal fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      type: map['type'] as String,
      target: (map['target'] as num).toDouble(),
      period: map['period'] as String,
    );
  }
}

class WeeklyReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalCalories;
  final double avgCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final Map<String, double> dayCalories;
  final List<String> tips;
  final List<String> messages;
  final double score;
  WeeklyReport({
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.avgCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.dayCalories,
    required this.tips,
    required this.messages,
    required this.score,
  });
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }
  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'eat_smart.db');
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE meals(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, calories REAL, protein REAL, carbs REAL, fat REAL, time INTEGER, tags TEXT)');
    await db.execute('CREATE TABLE goals(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, target REAL, period TEXT)');
    await db.execute('CREATE TABLE feedback(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, rating INTEGER, time INTEGER)');
    await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, weightKg REAL, heightCm REAL, age INTEGER)');
    await db.execute('CREATE TABLE conditions(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, type TEXT, notes TEXT, start INTEGER, end INTEGER)');
    await db.execute('CREATE TABLE dayplans(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, date INTEGER, items TEXT, completed INTEGER)');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, weightKg REAL, heightCm REAL, age INTEGER)');
      await db.execute('CREATE TABLE IF NOT EXISTS conditions(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, type TEXT, notes TEXT, start INTEGER, end INTEGER)');
      await db.execute('CREATE TABLE IF NOT EXISTS dayplans(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, date INTEGER, items TEXT, completed INTEGER)');
    }
  }
  Future<int> insertMeal(Meal meal) async {
    final database = await db;
    return database.insert('meals', meal.toMap());
  }
  Future<List<Meal>> getAllMeals() async {
    final database = await db;
    final res = await database.query('meals', orderBy: 'time DESC');
    return res.map(Meal.fromMap).toList();
  }
  Future<List<Meal>> getMealsInRange(DateTime start, DateTime end) async {
    final database = await db;
    final res = await database.query(
      'meals',
      where: 'time BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'time ASC',
    );
    return res.map(Meal.fromMap).toList();
  }
  Future<int> insertGoal(Goal goal) async {
    final database = await db;
    return database.insert('goals', goal.toMap());
  }
  Future<List<Goal>> getGoals() async {
    final database = await db;
    final res = await database.query('goals');
    return res.map(Goal.fromMap).toList();
  }
  Future<int> insertFeedback(String text, int rating) async {
    final database = await db;
    return database.insert('feedback', {'text': text, 'rating': rating, 'time': DateTime.now().millisecondsSinceEpoch});
  }
  Future<List<Map<String, dynamic>>> getFeedback() async {
    final database = await db;
    return database.query('feedback', orderBy: 'time DESC');
  }
  Future<User?> getCurrentUser() async {
    final database = await db;
    final res = await database.query('users', limit: 1);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }
  Future<int> insertUser(User user) async {
    final database = await db;
    return database.insert('users', user.toMap());
  }
  Future<List<Condition>> getActiveConditions(int userId) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final res = await database.query('conditions', where: '(userId = ?) AND (end IS NULL OR end >= ?)', whereArgs: [userId, now]);
    return res.map(Condition.fromMap).toList();
    }
  Future<int> insertCondition(Condition c) async {
    final database = await db;
    return database.insert('conditions', c.toMap());
  }
  Future<DayPlan?> getDayPlan(int userId, DateTime date) async {
    final database = await db;
    final day = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final res = await database.query('dayplans', where: 'userId = ? AND date = ?', whereArgs: [userId, day], limit: 1);
    if (res.isEmpty) return null;
    return DayPlan.fromMap(res.first);
  }
  Future<int> upsertDayPlan(DayPlan plan) async {
    final database = await db;
    if (plan.id != null) {
      return database.update('dayplans', plan.toMap(), where: 'id = ?', whereArgs: [plan.id]);
    }
    return database.insert('dayplans', plan.toMap());
  }
}

class AnalyticsService {
  final DatabaseService database;
  AnalyticsService(this.database);
  Future<WeeklyReport> buildWeeklyReport(DateTime anchor) async {
    final start = _startOfWeek(anchor);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    final meals = await database.getMealsInRange(start, end);
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    final dayCalories = <String, double>{};
    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      final k = DateFormat('EEE').format(d);
      dayCalories[k] = 0;
    }
    for (final m in meals) {
      totalCalories += m.calories;
      totalProtein += m.protein;
      totalCarbs += m.carbs;
      totalFat += m.fat;
      final k = DateFormat('EEE').format(DateTime(m.time.year, m.time.month, m.time.day));
      dayCalories[k] = (dayCalories[k] ?? 0) + m.calories;
    }
    final avgCalories = meals.isEmpty ? 0 : totalCalories / 7;
    final tips = _tips(meals, totalCalories, totalProtein, totalCarbs, totalFat);
    final messages = _messages(meals, avgCalories, dayCalories);
    final score = _score(meals, avgCalories, totalProtein, totalCarbs, totalFat);
    return WeeklyReport(
      startDate: start,
      endDate: end,
      totalCalories: totalCalories,
      avgCalories: avgCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      dayCalories: dayCalories,
      tips: tips,
      messages: messages,
      score: score,
    );
  }
  Future<WeeklyReport> buildMonthlyReport(DateTime anchor) async {
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 0, 23, 59, 59);
    final meals = await database.getMealsInRange(start, end);
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    final dayCalories = <String, double>{};
    final daysCount = end.day;
    for (int i = 1; i <= daysCount; i++) {
      dayCalories['$i'] = 0;
    }
    for (final m in meals) {
      totalCalories += m.calories;
      totalProtein += m.protein;
      totalCarbs += m.carbs;
      totalFat += m.fat;
      final k = '${m.time.day}';
      dayCalories[k] = (dayCalories[k] ?? 0) + m.calories;
    }
    final avgCalories = daysCount == 0 ? 0 : totalCalories / daysCount;
    final tips = _tips(meals, totalCalories, totalProtein, totalCarbs, totalFat);
    final messages = _messages(meals, avgCalories, dayCalories);
    final score = _score(meals, avgCalories, totalProtein, totalCarbs, totalFat);
    return WeeklyReport(
      startDate: start,
      endDate: end,
      totalCalories: totalCalories,
      avgCalories: avgCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      dayCalories: dayCalories,
      tips: tips,
      messages: messages,
      score: score,
    );
  }
  DateTime _startOfWeek(DateTime d) {
    final weekday = d.weekday;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }
  List<String> _tips(List<Meal> meals, double c, double p, double cb, double f) {
    final res = <String>[];
    if (p < cb * 0.2) res.add('Increase protein-rich meals');
    if (cb > p * 2) res.add('Balance carbs with protein and fiber');
    if (f > c * 0.35) res.add('Reduce high-fat items');
    final lateMeals = meals.where((m) => m.time.hour >= 21).length;
    if (lateMeals > 2) res.add('Reduce late-night eating');
    final tags = <String, int>{};
    for (final m in meals) {
      for (final t in m.tags) {
        tags[t] = (tags[t] ?? 0) + 1;
      }
    }
    if ((tags['veggies'] ?? 0) < 7) res.add('Add more vegetables');
    if ((tags['wholegrain'] ?? 0) < 4) res.add('Add whole grains');
    if (meals.isEmpty) res.add('Log meals consistently');
    return res;
  }
  List<String> _messages(List<Meal> meals, double avg, Map<String, double> dayCalories) {
    final res = <String>[];
    if (meals.length >= 14) res.add('Consistent logging');
    final lowDays = dayCalories.values.where((v) => v < avg * 0.7).length;
    if (lowDays <= 2) res.add('Stable intake');
    if (avg > 0) res.add('Keep improving');
    return res;
  }
  double _score(List<Meal> meals, double avg, double p, double cb, double f) {
    double s = 50;
    if (meals.length >= 21) s += 10;
    final balance = [p, cb, f];
    final total = p + cb + f;
    if (total > 0) {
      final ratios = balance.map((x) => x / total).toList();
      final ideal = [0.3, 0.5, 0.2];
      double diff = 0;
      for (int i = 0; i < 3; i++) {
        diff += (ratios[i] - ideal[i]).abs();
      }
      s += (1 - diff).clamp(0, 1) * 30;
    }
    if (avg > 0) s += 10;
    return s.clamp(0, 100);
  }
  List<String> buildPlanByCategory(String category, List<Condition> conditions) {
    final items = <String>[];
    if (category == 'Underweight') {
      items.addAll(['Breakfast: Oats + Yogurt', 'Lunch: Chicken + Rice + Salad', 'Dinner: Omelette + Wholegrain toast', 'Snack: Nuts/Apple']);
    } else if (category == 'Overweight') {
      items.addAll(['Breakfast: Oats + Fruit', 'Lunch: Grilled Chicken + Salad', 'Dinner: Veggie soup + Yogurt', 'Snack: Carrot sticks']);
    } else {
      items.addAll(['Breakfast: Oats + Yogurt', 'Lunch: Chicken + Brown Rice', 'Dinner: Salad + Omelette', 'Snack: Fruit']);
    }
    for (final c in conditions) {
      if (c.type.toLowerCase().contains('fever')) {
        items.add('Hydration: Water/ORS');
        items.add('Easy-to-digest foods');
      }
      if (c.type.toLowerCase().contains('accident')) {
        items.add('Protein for recovery');
        items.add('Vitamin C and Zinc sources');
      }
    }
    return items;
  }
}
