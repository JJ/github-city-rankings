# GitHub City Rankings


This project is a fork of [Top GitHub Users](https://github.com/paulmillr/top-github-users) by [Paul Miller](http://paulmillr.com/).

## Usage

First, create the directories where data is going to be placed. These directories will be defined in `config.json`.
Create an ID and SECRET in your GitHub account. If you don't, you wont be able to do more than a couple of runs per hour (20 request in total). Then, set them with

```basH
export GH_ID=LONG_HEXA_number
export GH_SECRET=EVEN_LONGER_HEXA_number
```


Install `node.js` and `coffeescript`. You're better off if you install `nvm` and then proceed from there. Once node is installed,

```bash
# Global install coffeescript
npm install -g coffee-script
# Install deps. from package.json
npm install
```

Cities can be configured by ECT templates, which reside in the `layout` dir; for the time being there is only one for Granada. If you want to use that template, or any other thing such as a particular output directory, create a configuration file such as this one

```
{
    "output_dir": "../top-github-users-data",
    "city" : "Granada",
    "layout": "granada.ect"
}
```

With that configuration file called `granada.json`, generate a ranking using
```
# Generate data
./get-city.coffee granada
```

If there is not such configuration file, the general `config.json` is used, and you can generate the ranking with

```
./get-city.coffee Málaga
```

## License

The MIT License (MIT)

Copyright (c) 2013,2014 Paul Miller (http://paulmillr.com/) JJ Merelo (http://jj.github.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
