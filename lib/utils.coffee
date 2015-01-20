fs = require 'fs'
MIN_CONTRIBUTIONS = 1

# Assorted utilities that don't go inside a class
module.exports = class Utils

    # Returns the set of users, filtered and sorted. 
    sortStats: (stats, excludes) ->

            Object.keys(stats)
            .filter (login) ->
                    stats[login].contributions >= MIN_CONTRIBUTIONS
            .filter (login) ->
                    if ( excludes )
                            login if not stats[login].location.match(excludes)
                    else
                            login
            .sort (a, b) ->
                    stats[b].contributions - stats[a].contributions
            .map (login) ->
                    stats[login]

    # Adds location string taking into account whitespace
    addLocation: (location ) ->
            if location.match(/\s+/)
                    "location:%22"+encodeURI(location)+"%22"
            else
                    "location:#{location}"

    # Writes in CSV format
    to_csv: ( an_array, file_name ) =>
            columns =  [ 'login','location','followers','contributions','stars','contributionsStreak','contributionsCurrentStreak']
            output = [ columns.join("; ") ]
            for row in an_array
                    this_row = []
                    this_row.push( row[column] ) for column in columns
                    output.push this_row.join( ";" )
            fs.writeFileSync( file_name, output.join("\n"))

