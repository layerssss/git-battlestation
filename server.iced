http = require 'http'
gitweb = require 'gitweb'
express = require 'express'
path = require 'path'
childProcess = require 'child_process'
fs = require 'fs'
request = require 'request'
expressSexyStatic = require 'express-sexy-static'
moment = require 'moment'
gravatar = require 'gravatar'

gitstat = require './gitstat.iced'

app = new express()
projectroot = path.resolve '.'
app.set 'view engine', 'jade'

app.locals.moment = moment
app.locals.gravatar = gravatar

app.set 'views', path.join __dirname, 'views'
await childProcess.exec 'hostname', defer e, out, err
console.error "unable to read hostname: #{e.message}" if e
app.set 'hostname', out
  


app.use express.static path.join __dirname, 'build'
app.use express.static path.join __dirname, 'public'

app.use '/repos', express.static path.join __dirname, 'gitweb-theme'
app.use '/fs', expressSexyStatic projectroot,
  theme: 'directory'

app.use express.bodyParser()
app.use (req, res, next)->
  req.body[k] = v for k, v of req.query
  next()
app.use express.methodOverride()

app.use (req, res, next)->
  if req.query.format == 'json'
    res.render = (template, locals)->
      obj = {}
      obj[k] = v for k, v of app.locals
      obj[k] = v for k, v of res.locals
      if locals
        obj[k] = v for k, v of locals
      res.json obj
  next()

app.get '/', (req, res)->
  res.render 'welcome'
app.locals.peers = {}
try
  app.locals.peers = JSON.parse fs.readFileSync '.git-battlestation-peers.json', 'utf8'
catch e

app.get '/who', (req, res)->
  res.send 'git-battlestation'

app.get '/peers/', (req, res)->
  res.render 'peers'

app.post '/peers/', (req, res, next)->
  await request "http://#{req.body.peer.host}/who", defer err, r, data
  console.log "http://#{req.body.peer.host}/who"
  return next new Error "git-battlestation not detected at #{req.body.peer.host}" if err || data!='git-battlestation'
  app.locals.peers[req.body.peer.alias] = req.body.peer.host
  res.redirect 'back'

app.delete '/peers/:peer', (req, res)->
  delete app.locals.peers[req.params.peer]
  res.redirect 'back'

app.param 'project', (req, res, next, project)->
  res.locals.repo = new gitstat path.join projectroot, project
  res.locals.project = project
  await res.locals.repo.branch defer e, branches
  return next e if e
  res.locals.repo.branches = branches
  next()

app.param 'branch', (req, res, next, branch)->
  res.locals.branch = branch
  await res.locals.repo.log branch, defer e, commits
  return next e if e
  res.locals.commits = commits
  next()

app.get '/compare/:project/:branch/', (req, res)->
  res.render 'compare'

app.get '/compare/:project/:branch/:peer/:peerBranch', (req, res, next)->
  res.locals.peer = req.params.peer
  res.locals.peerHost = app.locals.peers[req.params.peer]
  res.locals.peerBranch = req.params.peerBranch
  await request "http://#{res.locals.peerHost}/compare/#{res.locals.project}/#{req.params.peerBranch}/?format=json", defer e, r, data
  return next e if e 
  res.locals.peerData = JSON.parse data

  dic = {}
  for commit in res.locals.commits
    dic[commit.hash] = commit
  res.locals.peerData.unmerged = []
  for commit in res.locals.peerData.commits
    if dic[commit.hash]
      delete dic[commit.hash]
    else
      res.locals.peerData.unmerged.push commit
  res.locals.unmerged = []
  for hash, commit of dic
    res.locals.unmerged.push commit

  if res.locals.commits.length && res.locals.peerData.commits.length
    ldate = Date.parse res.locals.commits[res.locals.commits.length-1].date.trim()
    pdate = Date.parse res.locals.peerData.commits[res.locals.peerData.commits.length-1].date.trim()
    if ldate > pdate
      since = ldate
    else
      since = pdate
    res.locals.unmerged = res.locals.unmerged.filter (c)->since < Date.parse c.date
    res.locals.peerData.unmerged = res.locals.peerData.unmerged.filter (c)->since < Date.parse c.date
  res.render 'compare'

opt = 
  sitename: 'git-battlestation'
  projectroot: projectroot
  'max_depth': 2
app.use gitweb('/repos/', opt)


server = http.createServer(app)
server.listen Number(process.env.PORT||80), ->
  console.log "battle station fully charged on port #{server.address().port}"
  git = childProcess.spawn 'git', ['daemon', "--base-path=#{projectroot}", '--export-all'],
    stdio: 'inherit'
  git.on 'exit', (code)->
    throw new Error "git exited with #{code}"
  process.on 'uncaughtException', ->
    fs.writeFileSync (path.join projectroot,'.git-battlestation-peers.json'), (JSON.stringify app.locals.peers), 'utf8'
    git.kill()