request = require 'request'
cheerio = require 'cheerio'
cron = require('cron').CronJob
module.exports = (robot) ->
  new cron '52 2 * * *', () =>
    key = 'current_version'

    #currentVersion = robot.brain.get(key) ? '' 
    currentVersion = robot.brain.get(key) ? '4.4.9'
    robot.send room: '#general', '1'
    robot.send room: '#general', currentVersion

    options =
      url: 'http://php.net/downloads.php'
      timeout: 2000
      headers: {'user-agent': 'php version fetcher'}

    request options, (error, response, body) ->
      $ = cheerio.load body
      $('.release-state').each ->
        releaseState = $ @
        if releaseState.text() is 'Current Stable'
          newVersion = releaseState.parent().attr('id').replace(/v/, '')

          robot.send room: '#general', '2'
          robot.send room: '#general', newVersion
          if currentVersion isnt newVersion
            robot.send room: '#general', '3'
            robot.send room: '#general', 'PHP ' + newVersion + ' Released.'
            robot.brain.set(key, newVersion)
  , null, true, 'Asia/Tokyo'
