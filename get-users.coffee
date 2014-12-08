#!/usr/bin/env coffee
fs = require 'fs'
utils = require './utils'

id=process.env.GH_ID
secret=process.env.GH_SECRET
city=process.argv[2]

DISQUALIFIED = [
  'gugod'         # 7K commits in 4 days.
  'sindresorhus'  # Asked to remove himself from the list.
  'funkenstein'   # Appears in the list even though he has 30 followers (bug).
  'scottgonzalez' # Contribution graffiti.
  'beberlei' # 1.7K contribs every day
]

saveTopLogins = ->
  MIN_FOLLOWERS = 0
  MAX_PAGES = 10
  MIN_REPOS = 0
  urls = utils.range(1, MAX_PAGES + 1).map (page) -> [
      "https://api.github.com/search/users?client_id=#{id}&client_secret=#{secret}&q=location:"+city+"+followers:%3E#{MIN_FOLLOWERS}+repos:%3E#{MIN_REPOS}+sort:followers&per_page=100"
      "&page=#{page}"
    ].join('')

  parse = (text) ->
    JSON.parse(text).items.map (_) -> _.login

  utils.batchGet urls, parse, (all) ->
    logins = [].concat.apply [], all
    filtered = logins.filter (name) ->
      name not in DISQUALIFIED
    utils.writeStats './temp-logins.json', filtered

saveTopLogins()
