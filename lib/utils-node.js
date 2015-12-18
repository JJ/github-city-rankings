var fs = require('fs');
var Batch = require('batch');
var request = require('superagent');

var batchGet = exports.batchGet = function(urls, progressback, callback) {
    var batch = new Batch;
    var delay = 10;
    if ( urls.length > 20 && urls[0].match(/api/) ) {
	console.log( "API search, limiting" );
	batch.concurrency(1);
	delay = 1800;
    } else if  ( urls.length > 1000 ) { 
	batch.concurrency(1);
	delay = 10;
    } else {
	batch.concurrency(5);
    }
    urls.forEach(function(url) {
	batch.push(function(done) {
	    setTimeout( function() {
		request
		    .get(url)
		    .set('User-Agent', 'curl/7.24.0 (x86_64-ubuntu) libcurl/7.24.0 OpenSSL/0.9.8r zlib/1.2.5 gh-rankings-grx')
		    .end(function(error, response) {
			console.log("Done "+ url);
			if (error) throw new Error(error);
			if (response.error) {
			    if (response.status === 404) {
				done();
			    } else {
				throw [response.error,response.text].join("\n");
			    }
			}
			var result;
			try {
			    result = progressback(response.text);
			} catch (err) {
			    error = err;
			}
			done(error, result);
		    });
	    }, delay );
	});

    });

    batch.end(function(error, all) {
	if (error) throw new Error(error);
	callback(all);
    });
};

exports.range = function(start, end, step) {
  start = +start || 0;
  step = +step || 1;

  if (end == null) {
    end = start;
    start = 0;
  }
  // use `Array(length)` so V8 will avoid the slower "dictionary" mode
  // http://youtu.be/XAqIpGU8ZZk#t=17m25s
  var index = -1,
      length = Math.max(0, Math.ceil((end - start) / step)),
      result = Array(length);

  while (++index < length) {
    result[index] = start;
    start += step;
  }
  return result;
};



exports.getLast = function(city, id, secret, dir){
    result = fs.readFileSync(dir+"/data/user-data-"+city+".json", 'utf8');
    exports.data = JSON.parse(result);
};


// For debugging GitHub search.
var prop = function(name) {
  return function(item) {return item[name];};
};

var isNotIn = function(list) {
  return function(item) {return list.indexOf(item) === -1;};
};

var diff = function(prev, curr) {
  return prev.map(prop('login')).filter(isNotIn(curr.map(prop('login'))));
};

var reverseFind = function(list) {
  return function(login) {
    return list.filter(function(item) {
      return item.login === login;
    })[0];
  };
};

exports.prop = prop;
exports.isNotIn = isNotIn;
exports.diff = diff;
exports.reverseFind = reverseFind;
