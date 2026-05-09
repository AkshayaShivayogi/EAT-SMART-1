import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.db;
  runApp(const EatSmartApp());
}

class EatSmartApp extends StatelessWidget {
  const EatSmartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EAT-SMART',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const EntryGate(),
    );
  }
}

class EntryGate extends StatefulWidget {
  const EntryGate({super.key});
  @override
  State<EntryGate> createState() => _EntryGateState();
}
class _EntryGateState extends State<EntryGate> {
  User? user;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    final u = await DatabaseService.instance.getCurrentUser();
    setState(() {
      user = u;
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (user == null) return RegistrationPage(onDone: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell())));
    return LoginPage(user: user!);
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class LoginPage extends StatefulWidget {
  final User user;
  const LoginPage({super.key, required this.user});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Enter your name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  if (nameCtrl.text.trim().toLowerCase() == widget.user.name.trim().toLowerCase()) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name does not match')));
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final quotes = [
    'Small steps every day lead to big changes',
    'Fuel your body, feed your goals',
    'Consistency beats intensity',
    'Healthy choices, healthy life'
  ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Be Inspired'), content: Text(quotes[(DateTime.now().day) % quotes.length]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
    });
  }
  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const ReportsPage(), const PlanPage()];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Plan'),
        ],
        onDestinationSelected: (i) => setState(() => index = i),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Meal> meals = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    final res = await DatabaseService.instance.getAllMeals();
    setState(() {
      meals = res;
      loading = false;
    });
  }
  Future<void> _addMeal() async {
    final saved = await showModalBottomSheet<Meal>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const MealForm(),
    );
    if (saved != null) {
      await DatabaseService.instance.insertMeal(saved);
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great choice! Keep going.')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      floatingActionButton: FloatingActionButton(onPressed: _addMeal, child: const Icon(Icons.add)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: meals.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = meals[i];
                return ListTile(
                  title: Text(m.name),
                  subtitle: Text('${m.calories.toStringAsFixed(0)} kcal • P ${m.protein.toStringAsFixed(0)}g • C ${m.carbs.toStringAsFixed(0)}g • F ${m.fat.toStringAsFixed(0)}g'),
                  trailing: Text('${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}'),
                );
              },
            ),
    );
  }
}

class MealForm extends StatefulWidget {
  const MealForm({super.key});
  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  List<Map<String, dynamic>> foods = [];
  Map<String, dynamic>? selected;
  double quantity = 1;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _loadFoods();
  }
  Future<void> _loadFoods() async {
    final s = await rootBundle.loadString('assets/foods.json');
    final list = List<Map<String, dynamic>>.from(jsonDecode(s));
    setState(() {
      foods = list;
      selected = list.isNotEmpty ? list.first : null;
      loading = false;
    });
  }
  void _submit() {
    if (selected == null) return;
    final name = selected!['name'] as String;
    final calories = (selected!['calories'] as num).toDouble() * quantity;
    final protein = (selected!['protein'] as num).toDouble() * quantity;
    final carbs = (selected!['carbs'] as num).toDouble() * quantity;
    final fat = (selected!['fat'] as num).toDouble() * quantity;
    final tags = List<String>.from(selected!['tags'] as List);
    final meal = Meal(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat, time: DateTime.now(), tags: tags);
    Navigator.pop(context, meal);
  }
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: loading
            ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Add Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selected,
                      items: foods
                          .map((f) => DropdownMenuItem(value: f, child: Text(f['name'] as String)))
                          .toList(),
                      onChanged: (v) => setState(() => selected = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Quantity'),
                        Expanded(
                          child: Slider(
                            value: quantity,
                            min: 0.5,
                            max: 3,
                            divisions: 5,
                            label: quantity.toStringAsFixed(1),
                            onChanged: (v) => setState(() => quantity = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _submit, child: const Text('Save')),
                  ],
                ),
              ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  final VoidCallback onDone;
  const RegistrationPage({super.key, required this.onDone});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}
class _RegistrationPageState extends State<RegistrationPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final weight = TextEditingController();
  final height = TextEditingController();
  final age = TextEditingController();
  double bmi = 0;
  String category = '';
  List<String> tips = [];
  void _calc() {
    final w = double.tryParse(weight.text) ?? 0;
    final hcm = double.tryParse(height.text) ?? 0;
    final h = hcm/100.0;
    if (w > 0 && h > 0) {
      bmi = w/(h*h);
      if (bmi < 18.5) { category = 'Underweight'; tips = ['Increase meals and protein','Healthy snacks between meals']; }
      else if (bmi >= 25) { category = 'Overweight'; tips = ['Reduce refined carbs','Add vegetables and lean protein']; }
      else { category = 'Balanced'; tips = ['Maintain balanced macros','Stay consistent']; }
    } else { bmi = 0; category = ''; tips = []; }
    setState(() {});
  }
  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    final u = User(name: name.text.trim(), weightKg: double.parse(weight.text), heightCm: double.parse(height.text), age: int.parse(age.text));
    await DatabaseService.instance.insertUser(u);
    widget.onDone();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create your profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              TextFormField(controller: weight, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number, onChanged: (_) => _calc(), validator: (v) => (double.tryParse(v??'') ?? 0) > 0 ? null : 'Enter weight'),
              TextFormField(controller: height, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number, onChanged: (_) => _calc(), validator: (v) => (double.tryParse(v??'') ?? 0) > 0 ? null : 'Enter height'),
              TextFormField(controller: age, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v??'') ?? 0) > 0 ? null : 'Enter age'),
              const SizedBox(height: 12),
              Text('BMI ${bmi.toStringAsFixed(1)} ${category.isNotEmpty ? '• $category' : ''}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ...tips.map((t) => ListTile(leading: const Icon(Icons.check), title: Text(t))),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submit, child: const Text('Save and Continue')),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  WeeklyReport? report;
  bool loading = true;
  bool monthly = false;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    final analytics = AnalyticsService(DatabaseService.instance);
    final r = monthly ? await analytics.buildMonthlyReport(DateTime.now()) : await analytics.buildWeeklyReport(DateTime.now());
    setState(() {
      report = r;
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(monthly ? 'Monthly Report' : 'Weekly Report'),
        actions: [
          Switch(value: monthly, onChanged: (v) { setState(() { monthly = v; loading = true; }); _load(); })
        ],
      ),
      body: loading || report == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score ${report!.score.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('Calories ${report!.totalCalories.toStringAsFixed(0)}'),
                  Text('Protein ${report!.totalProtein.toStringAsFixed(0)}g'),
                  Text('Carbs ${report!.totalCarbs.toStringAsFixed(0)}g'),
                  Text('Fat ${report!.totalFat.toStringAsFixed(0)}g'),
                  const SizedBox(height: 16),
                SizedBox(height: 220, child: _calorieLineChart(report!.dayCalories)),
                  const SizedBox(height: 16),
                  SizedBox(height: 220, child: _macroPieChart(report!.totalProtein, report!.totalCarbs, report!.totalFat)),
                  const SizedBox(height: 16),
                  const Text('Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...report!.tips.map((t) => ListTile(leading: const Icon(Icons.lightbulb), title: Text(t))),
                  const SizedBox(height: 8),
                  const Text('Motivation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...report!.messages.map((m) => ListTile(leading: const Icon(Icons.favorite), title: Text(m))),
                ],
              ),
            ),
    );
  }
  Widget _calorieLineChart(Map<String, double> dayCalories) {
    final keys = dayCalories.keys.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), (dayCalories[keys[i]] ?? 0)));
    }
    return LineChart(LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
          final i = v.toInt();
          return Padding(padding: const EdgeInsets.only(top: 8), child: Text(i >= 0 && i < keys.length ? keys[i] : ''));
        })),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.green, barWidth: 3)],
    ));
  }
  Widget _macroPieChart(double p, double c, double f) {
    final total = p + c + f;
    final sections = [
      PieChartSectionData(value: p, title: total > 0 ? 'P ${(p / total * 100).toStringAsFixed(0)}%' : 'P 0%', color: Colors.blue, radius: 60),
      PieChartSectionData(value: c, title: total > 0 ? 'C ${(c / total * 100).toStringAsFixed(0)}%' : 'C 0%', color: Colors.orange, radius: 60),
      PieChartSectionData(value: f, title: total > 0 ? 'F ${(f / total * 100).toStringAsFixed(0)}%' : 'F 0%', color: Colors.red, radius: 60),
    ];
    return PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40));
  }
}

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});
  @override
  State<PlanPage> createState() => _PlanPageState();
}
class _PlanPageState extends State<PlanPage> {
  User? user;
  List<Condition> conditions = [];
  Map<DateTime, DayPlan> plans = {};
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    final db = DatabaseService.instance;
    final u = await db.getCurrentUser();
    if (u == null) { setState(() { loading = false; }); return; }
    final cond = await db.getActiveConditions(u.id!);
    final analytics = AnalyticsService(db);
    final category = _bmiCategory(u.weightKg, u.heightCm);
    final start = _startOfWeek(DateTime.now());
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      var existing = await db.getDayPlan(u.id!, date);
      if (existing == null) {
        final items = analytics.buildPlanByCategory(category, cond);
        existing = DayPlan(userId: u.id!, date: date, items: items, completed: false);
        await db.upsertDayPlan(existing);
      }
      plans[DateTime(date.year, date.month, date.day)] = existing;
    }
    setState(() { user = u; conditions = cond; loading = false; });
  }
  String _bmiCategory(double w, double hcm) {
    final h = hcm/100.0;
    final bmi = w/(h*h);
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 25.0) return 'Overweight';
    return 'Balanced';
  }
  DateTime _startOfWeek(DateTime d) {
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
  }
  Future<void> _toggleComplete(DayPlan plan, bool v) async {
    final updated = DayPlan(id: plan.id, userId: plan.userId, date: plan.date, items: plan.items, completed: v);
    await DatabaseService.instance.upsertDayPlan(updated);
    setState(() { plans[DateTime(plan.date.year, plan.date.month, plan.date.day)] = updated; });
  }
  Future<void> _addCondition() async {
    final t = TextEditingController();
    final n = TextEditingController();
    final res = await showDialog<Map<String,String>>(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Add Condition'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: t, decoration: const InputDecoration(labelText: 'Type')),
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Notes')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, {'type': t.text.trim(), 'notes': n.text.trim()}), child: const Text('Save')),
        ],
      );
    });
    if (res != null && user != null) {
      final c = Condition(userId: user!.id!, type: res['type']!, notes: res['notes']!, start: DateTime.now(), end: null);
      await DatabaseService.instance.insertCondition(c);
      await _load();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Plan'), actions: [IconButton(onPressed: _addCondition, icon: const Icon(Icons.medical_services))]),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: 7,
        itemBuilder: (_, i) {
          final date = _startOfWeek(DateTime.now()).add(Duration(days: i));
          final key = DateTime(date.year, date.month, date.day);
          final plan = plans[key];
          final label = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];
          if (plan == null) return ListTile(title: Text(label), subtitle: const Text('No plan'));
          return ExpansionTile(
            title: Text('$label • ${plan.completed ? 'Done' : 'Pending'}'),
            trailing: Checkbox(value: plan.completed, onChanged: (v) => _toggleComplete(plan, v ?? false)),
            children: plan.items.map((it) => ListTile(leading: const Icon(Icons.restaurant), title: Text(it))).toList(),
          );
        },
      ),
    );
  }
}
