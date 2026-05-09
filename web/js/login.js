import {storage, hash, showQuoteBanner, ensureApp} from './common.js'
if(location.protocol === 'file:'){
  alert('IMPORTANT: This app uses modern JavaScript modules which do not work when opened as a file. Please run "python -m http.server 8000" in the web folder and open http://localhost:8000/')
}
showQuoteBanner()
const authUsername = document.getElementById('authUsername')
const authPassword = document.getElementById('authPassword')
const btnLogin = document.getElementById('btnLogin')
const btnRegister = document.getElementById('btnRegister')
const authMsg = document.getElementById('authMsg')
let app = ensureApp()
function save(){storage.set('app', app)}
btnRegister.addEventListener('click', async ()=>{
  if(!authUsername.value || !authPassword.value){authMsg.textContent='Enter username and password';return}
  const pwd = await hash(authPassword.value)
  app.account = {u: authUsername.value.trim(), p: pwd}
  save()
  authMsg.textContent='Registered. Please login.'
})
btnLogin.addEventListener('click', async ()=>{
  if(!app.account){authMsg.textContent='No account found. Please register first.';return}
  const ok = app.account.u.toLowerCase() === authUsername.value.trim().toLowerCase() && app.account.p === await hash(authPassword.value)
  if(!ok){authMsg.textContent='Invalid credentials';return}
  location.href = 'profile.html'
})
