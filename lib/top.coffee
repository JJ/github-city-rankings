utils_node = require './utils-node'
Utils = require './utils.coffee'
cheerio = require 'cheerio'
fs = require 'fs'

DISQUALIFIED = [
        'rankingfaker' #good try, buster
        'Pablo-Merino' #github graffiti
        'andresgsaravia' #from Mexico
        'oscaruhp' #Mexico
        'ArianCastillo' #Mexico
        'sandritascs'
        'fbobbio' # from Argentina
        'pablocelayes' #from Argentina
  'gugod'         # 7K commits in 4 days.
  'sindresorhus'  # Asked to remove himself from the list.
  'funkenstein'   # Appears in the list even though he has 30 followers (bug).
  'scottgonzalez' # Contribution graffiti.
  'beberlei' # 1.7K contribs every day
]

MAX_PAGES = 10
CUTOFF = 5

# Class ranking. Processes ranking and saves info to files.
class Top

        #Class constructor. Needs the name of the city for file
        #creation, checks if there is a specific configuration file
        constructor: ( city, id, secret ) ->
                @utils = new Utils
                if  fs.existsSync "#{city}.json"
                        @config = JSON.parse fs.readFileSync("#{city}.json",'utf8')
                        @config.get_last = true
                        @city = @config.city
                        @big = @config.big
                        if @config.cutoff
                                @cutoff = @config.cutoff
                                console.log @cutoff
                        else
                                @cutoff = CUTOFF

                        if @config.location
                                locations =  @config.location.map (loc) =>
                                        @utils.addLocation( loc )
                                @location =  locations.join("+")
                        else
                                @location=@utils.addLocation(@city)

                        if @config.max_pages
                                @max_pages = @config.max_pages
                        else
                                @max_pages = MAX_PAGES

                else
                        @config = JSON.parse fs.readFileSync('config.json','utf8')
                        @city = city
                        @location = @utils.addLocation(city)
                        @max_pages = MAX_PAGES
                        @big = false

                @output_dir = @config.output_dir
                @layout = @config.layout
                @id = id
                @secret = secret
                @logins = []
                @stats = []
                @sorted_stats = []
                if @config.get_last
                        utils_node.getLast(@city,id,secret,@output_dir)


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

          # compute stats
          userStats =
                name: byProp('name').text().trim()
                login: byProp('additionalName').text().trim()
                location: byProp('homeLocation').text().trim()
                join_date: $('.join-date').text().trim()
                language: (/\sin ([\w-+#\s\(\)]+)/.exec(pageDesc)?[1] ? '')
                gravatar: byProp('image').attr('href').replace(400,64)
                followers: getFollowers()
                user_stars: $('.vcard-stats > a:nth-child(2) > .vcard-stat-count').text().trim()
                stars : 0
                organizations: $('#site-container > div > div > div.column.one-fourth.vcard > div.clearfix > a').toArray().map(getOrgName)
                contributions: getInt $('#contributions-calendar > div:nth-child(3) > span.contrib-number').text()
                contributionsStreak: getInt $('#contributions-calendar > div:nth-child(4) > span.contrib-number').text()
                contributionsCurrentStreak: getInt $('#contributions-calendar > div:nth-child(5) > span.contrib-number').text()
          userStats.location = userStats.location.replace(/\;/g,",")
          userStats.location = userStats.location.replace(/\|/g,",")
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
                        if @config.get_last
                                k=1
                                for old_data in utils_node.data
                                  if(old_data['login']==user.login)
                                    break
                                  k++

                                if(k>user.lugar)#Up
                                  user.change="up"
                                else if(k<user.lugar)#Down
                                  user.change="down"

                                else #Equal
                                  user.change="equal"

                        data.usuarios.push( user )


                fs.writeFileSync(@output_dir+"/formatted/top-"+@city+".md"
                        , @renderer.render(@layout, data) )
                @sorted_stats

        # Does the API requests
        get_urls: =>
                urls=[]
                if ( !@big )
                        urls = utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:followers+type:user&per_page=100&page=#{page}"
                else
                        urls = utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:followers+type:user+followers:%3E#{@cutoff[0]}&per_page=100&page=#{page}"
                        for i in [1..@cutoff.length-1] by 1
                                max_range = min_range = -1
                                urls_less = []
                                if typeof @cutoff[i] isnt 'number'
                                        max_range = min_range = @cutoff[i][0]
                                        repo_cutoff = @cutoff[i][1]
                                        urls_less = utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3E#{repo_cutoff}&per_page=100&page=#{page}"
                                        if !@cutoff[i][2]
                                                urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}&per_page=100&page=#{page}" )
                                        else
                                                if typeof @cutoff[i][2] isnt 'string'
                                                        date_range =  @cutoff[i][2]
                                                        console.log date_range
                                                        old_date = date_range[0]
                                                        mid_old_date = date_range[1]
                                                        mid_date = date_range[2]
                                                        mid_new_date = date_range[3]
                                                        new_date = date_range[4]
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:%3C#{old_date}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:%3E#{new_date}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:#{old_date}..#{mid_old_date}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:#{mid_old_date}..#{mid_date}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:#{mid_date}..#{mid_new_date}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:#{mid_new_date}..#{new_date}&per_page=100&page=#{page}" )
                                                else
                                                        date_cutoff=@cutoff[i][2]
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:%3E#{date_cutoff}&per_page=100&page=#{page}" )
                                                        urls_less = urls_less.concat( utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:repositories+type:user+followers:#{min_range}..#{max_range}+repos:%3C%3D#{repo_cutoff}+created:%3C%3D#{date_cutoff}&per_page=100&page=#{page}" )
                                else
                                        max_range = @cutoff[i-1]-1
                                        min_range = @cutoff[i]
                                        urls_less = utils_node.range(1, @max_pages + 1).map (page) => "https://api.github.com/search/users?client_id=#{@id}&client_secret=#{@secret}&q="+@location+"+sort:followers+type:user+followers:#{min_range}..#{max_range}&per_page=100&page=#{page}"

                                urls=urls.concat(urls_less)
                urls

        # Retrieves logins and puts everything else in motion
        get_logins: ( renderer ) =>
                @renderer = renderer
                urls = @get_urls()
                parse = (text) =>
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
