import {ensureApp, storage, computeBMI, showQuoteBanner} from './common.js'
showQuoteBanner()
const app = ensureApp()
const nameEl = document.getElementById('name')
const ageEl = document.getElementById('age')
const weightEl = document.getElementById('weight')
const heightEl = document.getElementById('height')
const goalEl = document.getElementById('goal')
const dietTypeEl = document.getElementById('dietType')
const btnSaveProfile = document.getElementById('btnSaveProfile')
const bmiResult = document.getElementById('bmiResult')
const bmiTips = document.getElementById('bmiTips')
const dietSuggestEl = document.getElementById('dietSuggest')
function renderFromProfile(){
  const p = app.profile
  if(!p) return
  nameEl.value = p.name||''
  ageEl.value = p.age||''
  weightEl.value = p.weight||''
  heightEl.value = p.height||''
  goalEl.value = p.goal||'maintain'
  dietTypeEl.value = p.dietType||'nonveg'
  updateBMI()
  updateDietSuggestions()
}
function updateBMI(){
  const w = parseFloat(weightEl.value||'0')
  const hcm = parseFloat(heightEl.value||'0')
  if(w>0 && hcm>0){
    const info = computeBMI(w,hcm)
    bmiResult.textContent = `BMI ${info.bmi.toFixed(1)} • ${info.category}`
    bmiTips.innerHTML = info.tips.map(t=>`<li>${t}</li>`).join('')
    return info
  } else {
    bmiResult.textContent = ''
    bmiTips.innerHTML = ''
    return null
  }
}
function updateDietSuggestions(){
  const info = updateBMI()
  const out = []
  if(info){
    if(info.category==='Underweight'){
      out.push('Eat frequent balanced meals with protein')
      out.push('Include nuts, milk, yogurt for extra calories')
    } else if (info.category==='Overweight'){
      out.push('Prioritize vegetables, lean protein, whole grains')
      out.push('Reduce refined carbs and avoid junk food')
    } else {
      out.push('Maintain balanced macros and consistent meal timing')
    }
  }
  if(goalEl.value==='loss'){out.push('Target modest calorie deficit and daily activity')}
  if(goalEl.value==='gain'){out.push('Add healthy snacks and strength training')}
  out.push('Drink more water')
  dietSuggestEl.innerHTML = out.map(x=>`<li>${x}</li>`).join('')
}
weightEl.addEventListener('input', updateDietSuggestions)
heightEl.addEventListener('input', updateDietSuggestions)
goalEl.addEventListener('change', updateDietSuggestions)
dietTypeEl.addEventListener('change', updateDietSuggestions)
btnSaveProfile.addEventListener('click', ()=>{
  if(!nameEl.value || !ageEl.value || !weightEl.value || !heightEl.value) return
  const info = computeBMI(parseFloat(weightEl.value), parseFloat(heightEl.value))
  app.profile = {name:nameEl.value.trim(), age:parseInt(ageEl.value), weight:parseFloat(weightEl.value), height:parseFloat(heightEl.value), bmi:info.bmi, category:info.category, goal:goalEl.value, dietType:dietTypeEl.value}
  storage.set('app', app)
  location.href='intake.html'
})
renderFromProfile()
