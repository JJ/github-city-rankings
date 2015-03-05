#!/usr/bin/env coffee

ECT = require 'ect'
fs = require 'fs'
glob = require 'glob'
Utils = require './lib/utils'
layout = "layout.ect"

glob '../top-github-users-data/data/user-data-*.json',{}, ( error, files ) =>
        users = []
        user_logins = {}
        if error
                exit
        for filename in files when filename isnt '../top-github-users-data/data/user-data-España.json'
                file = fs.readFileSync filename, 'utf8'
                these_users = JSON.parse file
                for user in these_users
                        if not user_logins[user.login]
                                users.push user
                                user_logins[user.login] = user
                        
        sorted_users = users.sort (a, b) ->
                b.contributions - a.contributions

        renderer = ECT({ root : 'layout' });
        today = new Date()
        from = new Date()
        from.setYear today.getFullYear() - 1
        data=
                start_date: from.toGMTString()
                end_date: today.toGMTString()
                ciudad : "Spain"
                usuarios: []

        i=1
        for user in users[0..999]
                user.lugar = i++
                data.usuarios.push( user )

        fs.writeFileSync "../top-github-users-data/formatted/top-alt-Spain.md", renderer.render( layout, data )
        utils = new Utils
        utils.to_csv( users, "../top-github-users-data/data/aggregated-top-Spain.csv", [ 'login','location','followers','contributions','stars','language' ])



