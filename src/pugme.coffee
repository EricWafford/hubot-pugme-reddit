# Description:
#   Pugme is the most important thing in life
#
# Dependencies:
#   underscore
#
# Configuration:
#   None
#
# Commands:
#   hubot pug me - Receive a pug
#   hubot pug bomb N - Get N pugs

_ = require 'underscore'

module.exports = (robot) ->

  robot.respond /pug me|pug bomb( (\d+))?/i, (msg) ->
    count = msg.match[2]
    if not count
      count = if (msg.match.input.match /bomb/i)? then 5 else 1

    msg.http("https://www.reddit.com/r/pugs.json?sort=top&t=week")
    .get() (err, res, body) ->
      try
        pugs = getPugs(body, count)
      catch error
        robot.logger.error "[pugme] #{error}"
        msg.send "I'm brain damaged :("
        return

      msg.send pug for pug in pugs

getPugs = (response, n) ->
  try
    posts = JSON.parse response
  catch error
    throw new Error "JSON parse failed"

  unless posts.data?.children? && posts.data.children.length > 0
    throw new Error "Could not find any posts"

  imagePosts = _.filter posts.data.children, (child) -> not child.data.is_self

  if n > imagePosts.length
    n = imagePosts.length

  return (imagePost.data.url for imagePost in (_.sample imagePosts, n))
