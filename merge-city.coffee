#!/usr/bin/env coffee

ECT = require 'ect'
fs = require 'fs'
glob = require 'glob'
Utils = require './lib/utils'
layout = "layout.ect"


glob '../top-github-users-data/data/user-data-*.json', {}, ( error, files ) =>
        users = []
        user_logins = {}
        if error
                exit
        files_biggies = files.filter ( f ) -> f.match( /(Catalunya|España|Andaluc)/ )
        files_not_biggies = files.filter ( f ) -> ! f.match( /(Catalunya|España|Andaluc)/ )
        files = files_biggies.concat files_not_biggies
        for filename in files
                do (filename ) =>
                        place = /data-([^-]+)\./.exec(filename);
                        file = fs.readFileSync filename, 'utf8'
                        these_users = JSON.parse file
                        for user in these_users
                                do ( user ) =>
                                        if not user_logins[user.login]
                                                user.place = place[1]
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
        utils.to_csv( users, "../top-github-users-data/data/aggregated-top-Spain.csv", [ 'login','location','place','followers','contributions','stars','user_stars', 'language' ])



