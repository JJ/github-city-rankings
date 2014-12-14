#!/usr/bin/env coffee

Top = require './lib/top'

id=process.env.GH_ID
secret=process.env.GH_SECRET
city=process.argv[2] || "Vigo"

top_city = new Top city, id, secret
top_city.get_logins (all) =>
        console.log( top_city )

