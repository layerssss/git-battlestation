path = require 'path'
{
  Parser
} = require 'header-stack'

module.exports = class gitstat
  constructor: (dir)->
    @dir = path.resolve dir

  exec: (cmd, cb)->
    cmd = "git --work-tree #{@dir} --git-dir #{path.join @dir,'.git'} #{cmd}"
    opt = 
      maxBuffer: Number.maxValue
    await (require 'child_process').exec cmd, opt , defer e, out, err
    cb e, out, err

  branch: (cb)->
    await @exec "branch", defer e, out, err
    cb e, out.match /[^\s]+$/mg

  log: (branch, cb)->
    await @exec "log -b #{branch} --max-count=100", defer e, out, err
    return cb e if e

    commits = []
    out = '\n' + out
    for commit,i in out.split '\ncommit '
      continue if !commit.length
      parser = new Parser 
        emitFirstLine: true
        strictSpaceAfterColon: true

      commits.push c = {}

      parser.on 'firstLine', (firstLine)->
        c.hash = firstLine
      parser.on 'headers', (headers, leftover)->
        c.author = headers.author
        c.date = headers.date
        c.merge = headers.merge
        c.message = leftover.toString('utf8').replace(/[\s\n]+/g,' ').trim()

      parser.on 'error', (e)->
        console.error e

      parser.parse commit
      
    
    cb null, commits
