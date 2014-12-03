#!/usr/bin/env nodejs

var columns = [ 'login','location','followers','contributions','contributionsStreak','contributionsCurrentStreak'];
var fs=require('fs');
var json_file = process.argv[2] || 'raw/github-users-stats.json';
fs.readFile( json_file, 'utf8', function( err,data ) {
    if ( err ) {
	return console.log( err );
    } else {
	var content = JSON.parse( data );
	if (content ) {
	    console.log(" ,", columns.join(", "));
	    for ( var i in content ) {
		var this_user = content[i];
		var this_user_array = new Array;
		for ( var j in columns ) {
		    this_user_array.push( this_user[columns[j]]);
		}
		console.log( this_user_array.join( ", "));
	    }
	}
    }
});
    

		    
		    
	
