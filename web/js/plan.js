import {ensureApp, storage, days, buildPlan, showQuoteBanner} from './common.js'
showQuoteBanner()
const app = ensureApp()
const planList = document.getElementById('planList')
function save(){storage.set('app', app)}
function ensurePlan(){
  const items = buildPlan(app.profile||{}, app.conditions||[])
  for(let i=0;i<7;i++){if(!app.weekly.items[i] || app.weekly.items[i].length===0) app.weekly.items[i] = items.slice()}
  save()
}
function updatePlanUI(){
  planList.innerHTML = ''
  for(let i=0;i<7;i++){
    const dayTitle = `${days[i]} • ${app.weekly.done[i] ? 'Done' : 'Pending'}`
    const container = document.createElement('div')
    container.className = 'dayPlan'
    const title = document.createElement('h3')
    title.textContent = dayTitle
    const checkbox = document.createElement('input')
    checkbox.type='checkbox'
    checkbox.checked = app.weekly.done[i]
    checkbox.addEventListener('change', ()=>{app.weekly.done[i]=checkbox.checked; save(); updatePlanUI()})
    const items = document.createElement('div')
    items.innerHTML = app.weekly.items[i].map(x=>`<div>• ${x}</div>`).join('')
    const comment = document.createElement('textarea')
    comment.placeholder = 'Your experience for the day'
    comment.value = app.weekly.comments[i] || ''
    comment.addEventListener('input', ()=>{app.weekly.comments[i]=comment.value; save()})
    container.appendChild(title)
    container.appendChild(checkbox)
    container.appendChild(items)
    container.appendChild(comment)
    planList.appendChild(container)
  }
}
ensurePlan()
updatePlanUI()
