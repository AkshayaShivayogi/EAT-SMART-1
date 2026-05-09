import {ensureApp, storage, days, foods, showQuoteBanner} from './common.js'
showQuoteBanner()
const app = ensureApp()
const daySelect = document.getElementById('daySelect')
const foodSelect = document.getElementById('foodSelect')
const foodQty = document.getElementById('foodQty')
const btnAddFood = document.getElementById('btnAddFood')
const dailySummary = document.getElementById('dailySummary')
const condInput = document.getElementById('condInput')
const btnAddCond = document.getElementById('btnAddCond')
const condList = document.getElementById('condList')
days.forEach((d,i)=>{const opt=document.createElement('option');opt.value=i;opt.textContent=d;daySelect.appendChild(opt)})
foods.forEach(f=>{const opt=document.createElement('option');opt.value=f.name;opt.textContent=`${f.name} (${f.cal} kcal)`;foodSelect.appendChild(opt)})
function save(){storage.set('app', app)}
btnAddFood.addEventListener('click', ()=>{
  const di = parseInt(daySelect.value)
  const item = foods.find(x=>x.name === foodSelect.value)
  const qty = parseFloat(foodQty.value||'1')
  const addCal = Math.max(0, item.cal * qty)
  app.weekly.intake[di] += addCal
  app.weekly.items[di].push(`${item.name} x${qty}`)
  save()
  updateDailySummary(di)
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
})
function renderConditions(){condList.innerHTML = app.conditions.map(c=>`<li>${c}</li>`).join('')}
renderConditions()
