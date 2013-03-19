Tweets = new Meteor.Collection "tweets"

#To be switched by your Twitter username
username = 'etienne_tremel'

twitterUrl = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=' + username + '&callback=?'

#Set interval to fetch tweets and prevent limitation (1 call per minute) from Twitter API check https://dev.twitter.com/docs/rate-limiting/1.1
Meteor.startup ->
  fetchNewTweets()
  Meteor.setInterval ( => fetchNewTweets()), 60000

fetchNewTweets = ->
  #Fetch Tweets from Twitter
  Meteor.http.get twitterUrl, (error, datas) ->
    for index, tweet of datas.data
      current_tweet = Tweets.find { id: tweet.id }
      if ! current_tweet.count() #If tweet not in DB, insert it
        Tweets.insert {
          id: tweet.id
          date: timeAgo tweet.created_at
          text: linkTweet tweet.text
        }


###
  Relative time calculator
  @param {string} twitter date string returned from Twitter API
  @return {string} relative time like "2 minutes ago"
###
timeAgo = (dateString) ->
  rightNow = new Date;
  before= new Date dateString;
  diff = rightNow - before

  second = 1000
  minute = second * 60
  hour = minute * 60
  day = hour * 24
  week = day * 7

  if isNaN(diff) || diff < 0
    return ""

  if diff < second * 2
    return "right now"

  if diff < minute
    return Math.floor(diff/second) + " secondes ago"

  if diff < minute * 2
    return "about 1 minute ago"

  if diff < hour
    return Math.floor(diff/minute) + " minutes ago"

  if diff < hour * 2
    return "about 1 hour ago"

  if diff < day
    return Math.floor(diff/hour) + " hours ago"

  if diff > day && diff < day * 2
    return "yesterday"
  
  if diff < day * 365
    return Math.floor(diff/day) + " days ago"
  else
    return "over a year ago"


###
Generate links to #Hash and @User
###
linkTweet = ( msg ) ->
  msg = msg.replace /(\#([^ ]+))+/g, '<a href="http://twitter.com/search?q=%23$2">$1</a>'
  msg.replace /(\@([^ ]+))+/g, '<a href="http://twitter.com/$2">$1</a>'