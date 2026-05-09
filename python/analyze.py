import json, os, datetime, statistics
base = os.path.dirname(os.path.dirname(__file__))
foods_path = os.path.join(base, 'assets', 'foods.json')
with open(foods_path, 'r', encoding='utf-8') as f:
    foods = json.load(f)
items = {x['name']: x for x in foods}
today = datetime.date.today()
start = today - datetime.timedelta(days=today.weekday())
def add(meals, name, qty, day_offset, hour):
    f = items[name]
    dt = datetime.datetime.combine(start + datetime.timedelta(days=day_offset), datetime.time(hour=hour))
    meals.append({
        'name': name,
        'calories': f['calories']*qty,
        'protein': f['protein']*qty,
        'carbs': f['carbs']*qty,
        'fat': f['fat']*qty,
        'time': int(dt.timestamp()*1000),
        'tags': f['tags']
    })
meals = []
add(meals,'Oats',1,0,8)
add(meals,'Greek Yogurt',1,0,10)
add(meals,'Grilled Chicken',1,0,13)
add(meals,'Brown Rice',1,0,13)
add(meals,'Green Salad',1,0,19)
add(meals,'Egg Omelette',1,1,8)
add(meals,'Apple',1,1,16)
add(meals,'Grilled Chicken',1,2,14)
add(meals,'Brown Rice',1,2,14)
add(meals,'Green Salad',1,2,19)
tot_c = sum(x['calories'] for x in meals)
tot_p = sum(x['protein'] for x in meals)
tot_cb = sum(x['carbs'] for x in meals)
tot_f = sum(x['fat'] for x in meals)
days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
day_cals = {d:0 for d in days}
for m in meals:
    dt = datetime.datetime.fromtimestamp(m['time']/1000)
    day_cals[days[dt.weekday()]] += m['calories']
avg_c = statistics.mean([v for v in day_cals.values()])
tips = []
if tot_p < tot_cb*0.2: tips.append('Increase protein-rich meals')
if tot_cb > tot_p*2: tips.append('Balance carbs with protein and fiber')
if tot_f > tot_c*0.35: tips.append('Reduce high-fat items')
late = len([m for m in meals if datetime.datetime.fromtimestamp(m['time']/1000).hour >= 21])
if late > 2: tips.append('Reduce late-night eating')
messages = []
if len(meals) >= 14: messages.append('Consistent logging')
low_days = len([v for v in day_cals.values() if v < avg_c*0.7])
if low_days <= 2: messages.append('Stable intake')
if avg_c > 0: messages.append('Keep improving')
total = tot_p + tot_cb + tot_f
score = 50
if len(meals) >= 21: score += 10
if total > 0:
    ratios = [tot_p/total, tot_cb/total, tot_f/total]
    ideal = [0.3, 0.5, 0.2]
    diff = sum(abs(ratios[i]-ideal[i]) for i in range(3))
    score += max(0, min(1, 1-diff))*30
if avg_c > 0: score += 10
score = max(0, min(100, score))
out = {
    'startDate': start.isoformat(),
    'endDate': (start + datetime.timedelta(days=6)).isoformat(),
    'totalCalories': round(tot_c,2),
    'avgCalories': round(avg_c,2),
    'totalProtein': round(tot_p,2),
    'totalCarbs': round(tot_cb,2),
    'totalFat': round(tot_f,2),
    'dayCalories': day_cals,
    'tips': tips,
    'messages': messages,
    'score': round(score,2)
}
print(json.dumps(out, ensure_ascii=False, indent=2))
