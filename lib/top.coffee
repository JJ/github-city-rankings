utils = require './utils-node'
cheerio = require 'cheerio'
fs = require 'fs'

DISQUALIFIED = [
  'gugod'         # 7K commits in 4 days.
  'sindresorhus'  # Asked to remove himself from the list.
  'funkenstein'   # Appears in the list even though he has 30 followers (bug).
  'scottgonzalez' # Contribution graffiti.
  'beberlei' # 1.7K contribs every day
]

MIN_FOLLOWERS = 0
MAX_PAGES = 10
MIN_REPOS = 0

sortStats = (stats) ->
        minContributions = 1
        Object.keys(stats)
        .filter (login) ->
                stats[login].contributions >= minContributions
        .sort (a, b) ->
                stats[b].contributions - stats[a].contributions
        .map (login) ->
                stats[login]

                
class Top
        constructor: ( city, id, secret ) ->
                if  fs.existsSync 'config.json'
                        @config = JSON.parse fs.readFileSync('config.json','utf8')
                @city = city
                @id = id
                @secret = secret
                @logins = []
                @stats = []
                @sorted_stats = []
                

        # Retrieves statistics for one user from the web site
        getStats: (html) =>
          $ = cheerio.load html
          byProp = (field) -> $("[itemprop='#{field}']")
          getInt = (text) -> parseInt text.replace ',', ''
          getOrgName = (item) -> $(item).attr('aria-label')
          getFollowers = ->
            text = $('.vcard-stats > a:nth-child(1) > .vcard-stat-count').text().trim()
            multiplier = if text.indexOf('k') > 0 then 1000 else 1
            (parseFloat text) * multiplier
        
          pageDesc = $('meta[name="description"]').attr('content')
        
          userStats =
                name: byProp('name').text().trim()
                login: byProp('additionalName').text().trim()
                location: byProp('homeLocation').text().trim()
                language: (/\sin ([\w-+#\s\(\)]+)/.exec(pageDesc)?[1] ? '')
                gravatar: byProp('image').attr('href')
                followers: getFollowers()
                organizations: $('#site-container > div > div > div.column.one-fourth.vcard > div.clearfix > a').toArray().map(getOrgName)
                contributions: getInt $('#contributions-calendar > div:nth-child(3) > span.contrib-number').text()
                contributionsStreak: getInt $('#contributions-calendar > div:nth-child(4) > span.contrib-number').text()
                contributionsCurrentStreak: getInt $('#contributions-calendar > div:nth-child(5) > span.contrib-number').text()
          @stats[userStats.login] = userStats
          userStats

        # Retrieves logins and puts everythin else in motion
        get_logins: ( callback ) =>
                urls = utils.range(1, MAX_PAGES + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q=location:"+@city+"+followers:%3E#{MIN_FOLLOWERS}+repos:%3E#{MIN_REPOS}+sort:followers&per_page=100&page=#{page}"

                parse = (text) ->
                    JSON.parse(text).items.map (_) -> _.login

                utils.batchGet urls, parse, (all) =>
                        logins = [].concat.apply [], all
                        @logins = logins.filter (name) ->
                              name not in DISQUALIFIED
                        urls = @logins.map (login) -> "https://github.com/#{login}"
                        utils.batchGet urls, this.getStats, =>
                                console.log "Batchget" 
                                console.log @stats 
                                @sorted_stats = sortStats @stats
                                fs.writeFileSync(@config.output_dir+"/data/user-data-"+@city+".json"
                                        , JSON.stringify(@sorted_stats))
                callback

module.exports = Top
