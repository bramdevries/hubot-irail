# Description:
#   Get information about trains in Belgium from hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   nmbs help
#   nmbs from <station> to <station>
#
# Author:
#   bramdevries

moment = require('moment-timezone')

module.exports = (robot) ->

  robot.respond /nmbs help/i, (msg) ->
    msg.reply "Here are all the commands for me."
    msg.send " *  nmbs from \"<station>\" to \"<station>\""

  robot.respond /nmbs from (.*) to (.*)/i, (msg) ->
    from = msg.match[1]
    to = msg.match[2]

    url = 'http://api.irail.be/connections/?from=' + from + '&to=' + to + '&format=json'

    robot.http(url).get() (err, res, body) ->
      if err
        msg.send 'There was an error: #{err}'
        return

      current = moment().tz('Europe/Berlin')
      message = 'The next train to ' + to + ' leaves';

      data = JSON.parse(body)
      connection = data.connection[0]

      departureTime = moment(connection.departure.time * 1000).tz('Europe/Berlin');

      minutes = departureTime.diff(current, 'minutes')

      if minutes == 0
        message += ' right now'
      else if minutes == 1
        message += ' in one minute'
      else
        message += ' in ' + minutes + ' minutes'

      message +=  ' (at ' + departureTime.format('HH:mm') + ')'

      message += ' from platform ' + connection.departure.platform + ' in ' + from + '.'

      delay = Math.round(connection.departure.delay / 60)

      message += ' It is currently delayed by ' + delay + ' minutes.' if delay > 0

      msg.send message
