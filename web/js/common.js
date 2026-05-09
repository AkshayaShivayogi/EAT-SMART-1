export const storage = {
  get(k){try{return JSON.parse(localStorage.getItem(k)||'null')}catch(e){return null}},
  set(k,v){localStorage.setItem(k, JSON.stringify(v))}
}
export async function hash(str){
  try {
    if (window.crypto && window.crypto.subtle) {
      const enc = new TextEncoder().encode(str)
      const buf = await window.crypto.subtle.digest('SHA-256', enc)
      return Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,'0')).join('')
    }
  } catch (_) {}
  let h = 0
  for (let i = 0; i < str.length; i++) { h = ((h << 5) - h) + str.charCodeAt(i); h |= 0 }
  return 'fallback_' + Math.abs(h)
}
export const quotes = [
  'Small steps every day lead to big changes',
  'Fuel your body, feed your goals',
  'Consistency beats intensity',
  'Healthy choices, healthy life'
]
export function showQuoteBanner(){
  const q = quotes[Math.floor(Math.random()*quotes.length)]
  const el = document.createElement('div')
  el.textContent = q
  el.style.cssText = 'position:fixed;left:50%;transform:translateX(-50%);bottom:20px;background:#2e7d32;color:#fff;padding:10px 14px;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,.2);z-index:9999'
  document.body.appendChild(el)
  setTimeout(()=>{el.remove()}, 3000)
}
export const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
export const foods = [
  {name:'Rice', cal:130},
  {name:'Roti', cal:100},
  {name:'Dal', cal:150},
  {name:'Egg', cal:70},
  {name:'Chicken', cal:240},
  {name:'Paneer', cal:265},
  {name:'Vegetables', cal:50},
  {name:'Fruits', cal:60},
  {name:'Milk', cal:120},
  {name:'Nuts', cal:170},
  {name:'Junk Food', cal:300}
]
export function computeBMI(weightKg, heightCm){
  const h = heightCm/100
  const bmi = weightKg/(h*h)
  let category = ''
  let tips = []
  if(bmi < 18.5){category='Underweight';tips=['Increase meals and protein','Healthy snacks between meals','Drink milk and include nuts']}
  else if(bmi >= 25){category='Overweight';tips=['Reduce refined carbs','Add vegetables and lean protein','Avoid junk food','Drink more water']}
  else {category='Balanced';tips=['Maintain balanced macros','Stay consistent','Keep daily hydration']}
  return {bmi, category, tips}
}
export function buildPlan(profile, conditions){
  const cat = profile?.category || 'Balanced'
  const diet = profile?.dietType || 'nonveg'
  const goal = profile?.goal || 'maintain'
  const baseVeg = cat==='Underweight' ? ['Breakfast: Oats + Yogurt','Lunch: Paneer + Rice + Salad','Dinner: Dal + Roti','Snack: Nuts/Apple']
               : cat==='Overweight' ? ['Breakfast: Oats + Fruit','Lunch: Paneer + Salad','Dinner: Veggie Soup + Yogurt','Snack: Carrot sticks']
               : ['Breakfast: Oats + Yogurt','Lunch: Dal + Brown Rice','Dinner: Salad + Omelette','Snack: Fruit']
  const baseNon = cat==='Underweight' ? ['Breakfast: Oats + Yogurt','Lunch: Chicken + Rice + Salad','Dinner: Omelette + Toast','Snack: Nuts/Apple']
               : cat==='Overweight' ? ['Breakfast: Oats + Fruit','Lunch: Grilled Chicken + Salad','Dinner: Veggie Soup + Yogurt','Snack: Carrot sticks']
               : ['Breakfast: Oats + Yogurt','Lunch: Chicken + Brown Rice','Dinner: Salad + Omelette','Snack: Fruit']
  let base = diet==='veg' ? baseVeg : baseNon
  if(goal==='loss'){base = base.map(it => it.replace('Rice','Brown Rice')).concat(['Hydration: 8 glasses water','Walk 30 minutes'])}
  if(goal==='gain'){base = base.concat(['Add calorie-dense snack','Milk or yogurt between meals'])}
  const extra = []
  for(const c of (conditions||[])){
    const t = c.toLowerCase()
    if(t.includes('fever')){extra.push('Hydration: Water/ORS','Easy-to-digest foods')}
    if(t.includes('accident')){extra.push('Protein for recovery','Vitamin C and Zinc sources')}
  }
  return [...base, ...extra]
}
export function requireAuth(){
  const app = storage.get('app')
  if(!app?.account){location.href='login.html'}
  return app
}
export function ensureApp(){
  let app = storage.get('app')
  if(!app){
    app = {account:null, profile:null, conditions:[], weekly:{intake:[0,0,0,0,0,0,0], items:Array(7).fill(null).map(()=>[]), done:Array(7).fill(false), comments:Array(7).fill('')}}
    storage.set('app', app)
  } else {
    // Ensure all required fields exist if the object was partially created (e.g. only account)
    if(!app.conditions) app.conditions = []
    if(!app.weekly) app.weekly = {intake:[0,0,0,0,0,0,0], items:Array(7).fill(null).map(()=>[]), done:Array(7).fill(false), comments:Array(7).fill('')}
    if(!app.profile) app.profile = null
  }
  return app
}
