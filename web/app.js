const quotes = [
  'Small steps every day lead to big changes',
  'Fuel your body, feed your goals',
  'Consistency beats intensity',
  'Healthy choices, healthy life'
]
function showQuote() {
  alert(quotes[Math.floor(Math.random()*quotes.length)])
}
document.addEventListener('DOMContentLoaded', showQuote)

const foods = [
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
const storage = {
  get(k){try{return JSON.parse(localStorage.getItem(k)||'null')}catch(e){return null}},
  set(k,v){localStorage.setItem(k, JSON.stringify(v))}
}
async function hash(str){
  const enc = new TextEncoder().encode(str)
  const buf = await crypto.subtle.digest('SHA-256', enc)
  return Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,'0')).join('')
}
const authUsername = document.getElementById('authUsername')
const authPassword = document.getElementById('authPassword')
const btnLogin = document.getElementById('btnLogin')
const btnRegister = document.getElementById('btnRegister')
const authMsg = document.getElementById('authMsg')
const nameEl = document.getElementById('name')
const ageEl = document.getElementById('age')
const weightEl = document.getElementById('weight')
const heightEl = document.getElementById('height')
const btnSaveProfile = document.getElementById('btnSaveProfile')
const bmiResult = document.getElementById('bmiResult')
const bmiTips = document.getElementById('bmiTips')
const goalEl = document.getElementById('goal')
const dietTypeEl = document.getElementById('dietType')
const dietSuggestEl = document.getElementById('dietSuggest')
const daySelect = document.getElementById('daySelect')
const foodSelect = document.getElementById('foodSelect')
const foodQty = document.getElementById('foodQty')
const btnAddFood = document.getElementById('btnAddFood')
const dailySummary = document.getElementById('dailySummary')
const condInput = document.getElementById('condInput')
const btnAddCond = document.getElementById('btnAddCond')
const condList = document.getElementById('condList')
const planList = document.getElementById('planList')
const tipsEl = document.getElementById('tips')
const motivationEl = document.getElementById('motivation')
const ctxCal = document.getElementById('caloriesChart')

const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
days.forEach((d,i)=>{
  const opt = document.createElement('option')
  opt.value = i
  opt.textContent = d
  daySelect.appendChild(opt)
})
foods.forEach(f=>{
  const opt = document.createElement('option')
  opt.value = f.name
  opt.textContent = `${f.name} (${f.cal} kcal)`
  foodSelect.appendChild(opt)
})

let app = storage.get('app') || {
  account: null,
  profile: null,
  conditions: [],
  weekly: {intake:[0,0,0,0,0,0,0], items: Array(7).fill(null).map(()=>[]), done:Array(7).fill(false), comments:Array(7).fill('')}
}
function save(){storage.set('app', app)}

btnRegister.addEventListener('click', async ()=>{
  if(!authUsername.value || !authPassword.value){authMsg.textContent='Enter username and password';return}
  const pwd = await hash(authPassword.value)
  app.account = {u: authUsername.value.trim(), p: pwd}
  save()
  authMsg.textContent='Registered. Please login.'
})
btnLogin.addEventListener('click', async ()=>{
  if(!app.account){authMsg.textContent='No account. Please register.';return}
  const ok = app.account.u.toLowerCase() === authUsername.value.trim().toLowerCase() && app.account.p === await hash(authPassword.value)
  if(!ok){authMsg.textContent='Invalid credentials';return}
  document.getElementById('authCard').style.display='none'
  document.getElementById('profileCard').style.display='block'
})

function calcBMI(){
  const w = parseFloat(weightEl.value||'0')
  const hcm = parseFloat(heightEl.value||'0')
  if(w>0 && hcm>0){
    const h = hcm/100
    const bmi = w/(h*h)
    let category = ''
    let tips = []
    if(bmi < 18.5){category='Underweight';tips=['Increase meals and protein','Healthy snacks between meals','Drink milk and include nuts']}
    else if(bmi >= 25){category='Overweight';tips=['Reduce refined carbs','Add vegetables and lean protein','Avoid junk food','Drink more water']}
    else {category='Balanced';tips=['Maintain balanced macros','Stay consistent','Keep daily hydration']}
    bmiResult.textContent = `BMI ${bmi.toFixed(1)} • ${category}`
    bmiTips.innerHTML = tips.map(t=>`<li>${t}</li>`).join('')
    return {bmi, category}
  } else {
    bmiResult.textContent = ''
    bmiTips.innerHTML = ''
    return null
  }
}
weightEl.addEventListener('input', calcBMI)
heightEl.addEventListener('input', calcBMI)

btnSaveProfile.addEventListener('click', ()=>{
  if(!nameEl.value || !ageEl.value || !weightEl.value || !heightEl.value){return}
  const bmiInfo = calcBMI()
  app.profile = {
    name:nameEl.value.trim(),
    age:parseInt(ageEl.value),
    weight:parseFloat(weightEl.value),
    height:parseFloat(heightEl.value),
    bmi:bmiInfo?bmiInfo.bmi:null,
    category:bmiInfo?bmiInfo.category:null,
    goal: goalEl.value,
    dietType: dietTypeEl.value
  }
  save()
  updateDietSuggestions()
  buildWeeklyPlan()
  updatePlanUI()
})

btnAddFood.addEventListener('click', ()=>{
  const dayIndex = parseInt(daySelect.value)
  const item = foods.find(x=>x.name === foodSelect.value)
  const qty = parseFloat(foodQty.value||'1')
  const addCal = Math.max(0, item.cal * qty)
  app.weekly.intake[dayIndex] += addCal
  app.weekly.items[dayIndex].push(`${item.name} x${qty}`)
  save()
  updateDailySummary(dayIndex)
  updateChart()
  updateTips()
})
function updateDailySummary(di){
  dailySummary.innerHTML = `<strong>${days[di]}</strong>: ${app.weekly.intake[di]} kcal<br>${app.weekly.items[di].map(x=>`• ${x}`).join('<br>')}`
}
btnAddCond.addEventListener('click', ()=>{
  const v = condInput.value.trim()
  if(!v) return
  app.conditions.push(v)
  condInput.value=''
  save()
  renderConditions()
  buildWeeklyPlan()
  updatePlanUI()
})
function renderConditions(){
  condList.innerHTML = app.conditions.map(c=>`<li>${c}</li>`).join('')
}

function buildWeeklyPlan(){
  const cat = app.profile?.category || 'Balanced'
  const diet = app.profile?.dietType || 'nonveg'
  const goal = app.profile?.goal || 'maintain'
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
  for(const c of app.conditions){
    const t = c.toLowerCase()
    if(t.includes('fever')){extra.push('Hydration: Water/ORS','Easy-to-digest foods')}
    if(t.includes('accident')){extra.push('Protein for recovery','Vitamin C and Zinc sources')}
  }
  const planItems = [...base, ...extra]
  for(let i=0;i<7;i++){
    app.weekly.items[i] = planItems.slice()
  }
  save()
}

function updateDietSuggestions(){
  const p = app.profile
  if(!p){dietSuggestEl.innerHTML='';return}
  const out = []
  if(p.category==='Underweight'){
    out.push('Eat frequent balanced meals with protein')
    out.push('Include nuts, milk, yogurt for extra calories')
  } else if (p.category==='Overweight'){
    out.push('Prioritize vegetables, lean protein, whole grains')
    out.push('Reduce refined carbs and avoid junk food')
  } else {
    out.push('Maintain balanced macros and consistent meal timing')
  }
  if(p.goal==='loss'){out.push('Target modest calorie deficit and daily activity')}
  if(p.goal==='gain'){out.push('Add healthy snacks and strength training')}
  out.push('Drink more water')
  dietSuggestEl.innerHTML = out.map(x=>`<li>${x}</li>`).join('')
}

function updatePlanUI(){
  planList.innerHTML = ''
  for(let i=0;i<7;i++){
    const dayTitle = `${days[i]} • ${app.weekly.done[i] ? 'Done' : 'Pending'}`
    const container = document.createElement('div')
    container.className = 'dayPlan'
    const checkbox = document.createElement('input')
    checkbox.type='checkbox'
    checkbox.checked = app.weekly.done[i]
    checkbox.addEventListener('change', ()=>{
      app.weekly.done[i] = checkbox.checked
      save()
      updatePlanUI()
    })
    const items = document.createElement('div')
    items.innerHTML = app.weekly.items[i].map(x=>`<div>• ${x}</div>`).join('')
    const comment = document.createElement('textarea')
    comment.placeholder = 'Your experience for the day'
    comment.value = app.weekly.comments[i] || ''
    comment.addEventListener('input', ()=>{
      app.weekly.comments[i] = comment.value
      save()
    })
    const title = document.createElement('h3')
    title.textContent = dayTitle
    container.appendChild(title)
    container.appendChild(checkbox)
    container.appendChild(items)
    container.appendChild(comment)
    planList.appendChild(container)
  }
}

let chart
function updateChart(){
  const labels = days
  const data = app.weekly.intake
  if(chart){chart.destroy()}
  chart = new Chart(ctxCal, {type:'line', data:{labels, datasets:[{label:'Calories', data, borderColor:'#2e7d32', tension:.3}]} , options:{responsive:true,plugins:{legend:{display:false}}}})
}
function updateTips(){
  const avg = app.weekly.intake.reduce((a,b)=>a+b,0)/7
  const t = []
  if(avg > 2200) t.push('You are consuming more calories than required')
  if(avg < 1600) t.push('You are consuming fewer calories than required')
  t.push('Drink more water')
  t.push('Avoid junk food')
  tipsEl.innerHTML = t.map(x=>`<li>${x}</li>`).join('')
  motivationEl.innerHTML = ['Consistent logging','Keep improving','Stay hydrated'].map(x=>`<li>${x}</li>`).join('')
}

function init(){
  document.getElementById('profileCard').style.display='none'
  renderConditions()
  updateChart()
  updateTips()
  if(app.profile){updateDietSuggestions();buildWeeklyPlan();updatePlanUI()}
}
init()
