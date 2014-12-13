# GitHub City Rankings


This project is a fork of [Top GitHub Users](https://github.com/paulmillr/top-github-users) by [Paul Miller](http://paulmillr.com/). Below is the original README. 

## Usage

Make sure you’ve got node.js and coffeescript installed. Create also the default directories, `raw` and `formatted`

```bash
# Install deps.
npm install
# Download and format everything.
make

# or

# Download data.
make get

# Generate stats.
make format
```

## Or also

Edit `get-city.sh` for your city and run

    ./get-city.sh 

To get the data on that city.

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
