utils_node = require './utils-node'
Utils = require './utils.coffee'
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


# Class ranking. Processes ranking and saves info to files.
class Top

        #Class constructor. Needs the name of the city for file
        #creation, checks if there is a specific configuration file
        constructor: ( city, id, secret ) ->
                @utils = new Utils
                if  fs.existsSync "#{city}.json"
                        @config = JSON.parse fs.readFileSync("#{city}.json",'utf8')
                        @city = @config.city
                        if @config.location
                                locations =  @config.location.map (loc) =>
                                        @utils.addLocation( loc )
                                @location =  locations.join("+")
                        else
                                @location=@utils.addLocation(@city)

                else
                        @config = JSON.parse fs.readFileSync('config.json','utf8')
                        @city = city
                        @location = @utils.addLocation(city)

                @output_dir = @config.output_dir
                @layout = @config.layout
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

          # compute stars
          userStats =
                name: byProp('name').text().trim()
                login: byProp('additionalName').text().trim()
                location: byProp('homeLocation').text().trim()
                language: (/\sin ([\w-+#\s\(\)]+)/.exec(pageDesc)?[1] ? '')
                gravatar: byProp('image').attr('href').replace(400,64)
                followers: getFollowers()
                stars : 0
                organizations: $('#site-container > div > div > div.column.one-fourth.vcard > div.clearfix > a').toArray().map(getOrgName)
                contributions: getInt $('#contributions-calendar > div:nth-child(3) > span.contrib-number').text()
                contributionsStreak: getInt $('#contributions-calendar > div:nth-child(4) > span.contrib-number').text()
                contributionsCurrentStreak: getInt $('#contributions-calendar > div:nth-child(5) > span.contrib-number').text()
          userStats.location = userStats.location.replace(/\;/g,",")
          @stats[userStats.login] = userStats
          userStats

        add_stars: (html) =>
            $ = cheerio.load html
            login = $("[itemprop='additionalName']").text().trim()
            userStats = @stats[login]
            userStats.stars += parseInt(num.children[2].data.trim()) for num in $("[aria-label='Stargazers']")

        # Formats and outputs files
        give_format: =>
                @sorted_stats = @utils.sortStats @stats, @config.exclude
                console.log "sorted_stats"
                console.log @sorted_stats 
                fs.writeFileSync(@output_dir+"/data/user-data-"+@city+".json"
                        , JSON.stringify(@sorted_stats))
                @utils.to_csv( @sorted_stats, @output_dir+"/data/user-data-"+@city+".csv")
                today = new Date()
                from = new Date()
                from.setYear today.getFullYear() - 1
                data=
                        start_date: from.toGMTString()
                        end_date: today.toGMTString()
                        ciudad : @city
                        usuarios: []
                i=1
                for user in @sorted_stats
                        user.lugar = i++
                        data.usuarios.push( user )
                fs.writeFileSync(@output_dir+"/formatted/top-"+@city+".md"
                        , @renderer.render(@layout, data) )
                @sorted_stats


        # Retrieves logins and puts everything else in motion
        get_logins: ( renderer ) =>
                @renderer = renderer
                urls = utils_node.range(1, MAX_PAGES + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+followers:%3E#{MIN_FOLLOWERS}+repos:%3E#{MIN_REPOS}+sort:followers&per_page=100&page=#{page}"

                parse = (text) ->
                    JSON.parse(text).items.map (_) -> _.login

                utils_node.batchGet urls, parse, (all) =>
                        logins = [].concat.apply [], all
                        @logins = logins.filter (name) ->
                              name not in DISQUALIFIED
                        urls = @logins.map (login) -> "https://github.com/#{login}"
                        utils_node.batchGet urls, this.getStats, =>
                                urls = @logins.map (login) -> "https://github.com/#{login}?tab=repositories"
                                utils_node.batchGet urls, this.add_stars, this.give_format





module.exports = Top
