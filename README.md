# Introduction

Bishop is a simple IRC-bot with a HTTP-interface on top and build with [Cinch](https://github.com/cinchrb/cinch) and [Sinatra](https://github.com/sinatra/sinatra).

# Install and configure

Lets get down to business:

    $ git clone git://github.com/ta/bishop.git
    $ cd bishop
    $ bundle install
    $ BISHOP_API_KEY=<key> BISHOP_SERVER=<server> BISHOP_CHANNEL=<hannel> bundle exec unicorn

Configuration is done using these environment variables:

* BISHOP_API_KEY - The secret key to to be used in the HTTP interface
* BISHOP_SERVER - The server name
* BISHOP_CHANNELS - A comma-separated list of channels bishop should join
* BISHOP_PORT - The port to connect to - use this if the server uses some non-standard port
* BISHOP_SSL_USE - If server uses SSL encryption, default is no
* BISHOP_SSL_VERIFY - If bishop should verify the SSL certificate, default is no
* BISHOP_LOG_VERBOSE - Log all requests and not just errors, default is no

### Heroku

This piece of software is easily used on the Heroku platform. It includes a Procfile so its just a matter of creating an App at Heroku, set the proper environment variables and deploy the code.

Please note that if you use Heroku's Free plan, your dyno will be put to sleep after idling for X time and bishop will disconnect from any IRC server. It will however wake up again if and when the App receives a HTTP request.

# Usage

In the spirit of getting down to business (Of course you need to replace host and port to your App's host and port):

### Start bot

    curl -d "apikey=<key>" "http://localhost:8080/start"

### Stop bot

    curl -d "apikey=<key>" "http://localhost:8080/stop"

### Join channel

    curl -d "apikey=<key>&channel=<channel>&password=<password>" "http://localhost:8080/join"

### Part channel

    curl -d "apikey=<key>&channel=<channel>&reason=<reason>" "http://localhost:8080/part"

### Action

    curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>" "http://localhost:8080/action"

### Notice

    curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>" "http://localhost:8080/notice"

### Message

    curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>&nick=<nick>" "http://localhost:8080/message"

### Ping

    curl "http://localhost:8080/ping"

# Todo

Open for suggestions

# Licence

Copyright (c) 2012 Tonni Aagesen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.