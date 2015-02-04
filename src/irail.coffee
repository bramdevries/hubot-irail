# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

moment = require('moment-timezone')

module.exports = (robot) ->

  robot.respond /nmbs from (.*) to (.*)/i, (msg) ->
    from = msg.match[1]
    to = msg.match[2]

    url = 'http://api.irail.be/connections/?from=' + from + '&to=' + to + '&format=json'

    robot.http(url).get() (err, res, body) ->
      if err
        msg.send 'There was an error: #{err}'
        return

      current = moment().tz('Europe/Berlin')
      message = 'The next train to ' + to;

      data = JSON.parse(body)
      connection = data.connection[0]

      departureTime = moment(connection.departure.time * 1000).tz('Europe/Berlin');

      message += ' leaves in ' + departureTime.diff(current, 'minutes') + ' minutes (at ' + departureTime.format('HH:mm') + ')'
      message += ' from platform ' + connection.departure.platform + ' in ' + from + '.'

      delay = Math.round(connection.departure.delay / 60)

      message += ' It is currently delayed by ' + delay + ' minutes.' if delay > 0

      msg.send message