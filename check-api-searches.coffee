#!/usr/bin/env coffee

Top = require './lib/top'

id=process.env.GH_ID
secret=process.env.GH_SECRET
city=process.argv[2] || "granada"

city_top = new Top city, id, secret

all_urls =  city_top.get_urls()

urls = url for url in all_urls when url.match(/page=1\b/)

console.log(urls)

