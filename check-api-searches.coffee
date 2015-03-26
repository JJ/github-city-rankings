#!/usr/bin/env coffee

Top = require './lib/top'
request = require 'superagent';

id=process.env.GH_ID
secret=process.env.GH_SECRET
city=process.argv[2] || "granada"

city_top = new Top city, id, secret

all_urls =  city_top.get_urls()

urls = ( url for url in all_urls when url.match(/page=1\b/) )

total_results = 0
requesting = ->
        url = urls.shift()
        if url 
                request.get(url).set('User-Agent', 'GHRankings seeker').end (error, response) ->
                        if error
                                return "Error : #{error}"
                        result = JSON.parse response.text
                        if result.total_count > 1000
                                console.log "URL #{url} returns #{result.total_count} users. Danger!!!"
                        total_results += result.total_count
                        setTimeout requesting, 0
        else # Done
                if city_top.max_pages && total_results > city_top.max_pages*100
                        console.log "Users #{total_results} not covered by #{city_top.max_pages} requests. Danger!!!"
                console.log "Users  #{total_results}"

requesting()
