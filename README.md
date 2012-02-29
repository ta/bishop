# Introduction

Bishop is a simple IRC-bot with a HTTP-interface on top and build with [Cinch](https://github.com/cinchrb/cinch) and [Sinatra](https://github.com/sinatra/sinatra).

# Install and configure

Lets get down to business:

    $ git clone git://github.com/ta/bishop.git
    $ cd bishop
    $ bundle install
    $ BISHOP_API_KEY=<key> BISHOP_SERVER=<server> BISHOP_CHANNELS=<hannel(s)> bundle exec unicorn

Configuration is done using these environment variables:

* BISHOP_API_KEY - The secret key to to be used in the HTTP interface
* BISHOP_SERVER - The server name
* BISHOP_CHANNELS - A comma-separated list of channels bishop should join
* BISHOP_PORT - The port to connect to, default is 6667 (or 6697 if BISHOP_SSL_USE is set)
* BISHOP_SSL_USE - If server uses SSL encryption, default is no
* BISHOP_SSL_VERIFY - If bishop should verify the SSL certificate, default is no
* BISHOP_LOG_VERBOSE - Log all requests and not just errors, default is no

These extra variables are available for feature-specific configuration - see the description of these features to find out more:

* BISHOP_GITHUB_HOOK_CHANNELS - A comma-separated list of channels where bishop should post github push messages
* BISHOP_HEROKU_HOOK_CHANNELS - A comma-separated list of channels where bishop should post heroku deploy messages
* BISHOP_REDMINE_HOOK_CHANNELS - A comma-separated list of channels where bishop should post redmine action messages

### Github Post-Receive Hooks

Bishop supports [Github's Post-Receive Hooks](http://help.github.com/post-receive-hooks/) feature out of the box. You only have set up a few things to get these beautiful messages in your IRC client:

    [22:00:55] -bishop- [github] http://git.io/-7HEiA committed by chris@ozmm.org with message: okay i give in
    [22:00:56] -bishop- [github] http://git.io/HN3GuQ committed by chris@ozmm.org with message: update pricing a tad

Use the following Post-Receive URL:

    http(s)://<your-site>/hooks/github/<BISHOP_API_KEY>

Configuration is done using these environment variables:

* BISHOP_GITHUB_HOOK_CHANNELS - A comma-separated list of channels where bishop should post github push messages

### Heroku HTTP Post Hook on deploy

Bishop supports [Heroku's HTTP Post Hook on deploy](http://devcenter.heroku.com/articles/deploy-hooks#http_post_hook) feature out of the box. You only have set up a few things to get these pretty messages in your IRC client:

    [22:00:55] -bishop- [your app] Rev. f6b11a090f deployed by your@email.tld

Use the following URL:

    http(s)://<your-site>/hooks/heroku/<BISHOP_API_KEY>

Configuration is done using these environment variables:

* BISHOP_HEROKU_HOOK_CHANNELS - A comma-separated list of channels where bishop should post heroku deploy messages

### Redmine Post-Action Hooks

Bishop supports the [Redmine Post-Action Hooks](https://github.com/ta/redmine_post_action_hooks) plugin for Redmine out of the box. You only have set up a few things to get these beautiful messages in your IRC client:

    [22:00:55] -bishop- [your project] ta updated issue "Test Issue" - https://domain.tld/issues/n
    # or if assigned to (but not updated by) another user
    [22:00:55] bishop: looser: [your project] ta updated issue "Test Issue" - https://domain.tld/issues/n

Use the following url:

    http(s)://<your-site>/hooks/redmine/<BISHOP_API_KEY>

Configuration is done using these environment variables:

* BISHOP_REDMINE_HOOK_CHANNELS - A comma-separated list of channels where bishop should post redmine action messages

### Heroku deployment

This project is easily deployed to and used on the Heroku platform. It even includes a Procfile for their Cedar stack so its just a matter of creating an App at Heroku, set the proper environment variables and deploy the code... like this:

    $ git clone git://github.com/ta/bishop.git
    $ cd bishop
    $ heroku apps:create <app-name> --stack cedar
    $ heroku config:add BISHOP_API_KEY=<key> BISHOP_SERVER=<server> BISHOP_CHANNELS=<channel(s)>
    $ git remote add heroku git@heroku.com:<app-name>.git
    $ git push heroku master

Please note that if you use Heroku's Free plan your dyno will be put to sleep after idling for X time and bishop will disconnect from any IRC server. The dyno will however wake up again if and when the App receives a HTTP request and bishop will reconnect again.

# Usage

In the spirit of getting down to business (Of course you need to replace host and port to your App's host and port):

### Start bot

    $ curl -d "apikey=<key>" "http://localhost:8080/start"

### Stop bot

    $ curl -d "apikey=<key>" "http://localhost:8080/stop"

### Join

    $ curl -d "apikey=<key>&channel=<channel>&password=<password>" "http://localhost:8080/join"

### Part

    $ curl -d "apikey=<key>&channel=<channel>&reason=<reason>" "http://localhost:8080/part"

### Action

    $ curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>" "http://localhost:8080/action"

### Notice

    $ curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>" "http://localhost:8080/notice"

### Message

    $ curl -d "apikey=<apikey>&recipient=<channel_or_user>&text=<text>&nick=<nick>" "http://localhost:8080/message"

### Ping

    $ curl "http://localhost:8080/ping"

# Todo

Open for suggestions

# Licence

Copyright (c) 2012 Tonni Aagesen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.