#!/usr/bin/env coffee

Top = require './lib/top'
ECT = require 'ect'
renderer = ECT({ root : 'layout' });

id=process.env.GH_ID
secret=process.env.GH_SECRET
city=process.argv[2] || "Vigo"

city_top = new Top city, id, secret

city_top.get_logins renderer

