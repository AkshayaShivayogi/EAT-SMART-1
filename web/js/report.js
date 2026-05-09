import {ensureApp, days, showQuoteBanner} from './common.js'
showQuoteBanner()
const app = ensureApp()
const tipsEl = document.getElementById('tips')
const motivationEl = document.getElementById('motivation')
const ctxCal = document.getElementById('caloriesChart')
let chart
function updateChart(){
  const labels = days
  const data = app.weekly.intake
  if(chart){chart.destroy()}
  chart = new Chart(ctxCal, {type:'line', data:{labels, datasets:[{label:'Calories', data, borderColor:'#2e7d32', tension:.3}]}, options:{responsive:true,plugins:{legend:{display:false}}}})
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
updateChart()
updateTips()
