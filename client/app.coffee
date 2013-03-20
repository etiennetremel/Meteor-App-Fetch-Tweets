Tweets = new Meteor.Collection "tweets"

Template.tweets.latestTweet = ->
  if Tweets.find({}).count()
    for tweet in Tweets.find({}, {limit: 10}).fetch() #Fetch tweets and limit the number to 10
      { date: timeAgo(tweet.date), text: linkTweet(tweet.text) }
      

###
  Relative time calculator
  @param {string} twitter date string returned from Twitter API
  @return {string} relative time like "2 minutes ago"
###
timeAgo = (dateString) ->
  rightNow = new Date;
  before= new Date(dateString);
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
  #Links
  links_pattern = /(^|\s)((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/gi
  links = msg.match links_pattern
  if links != null
    for link in links

      #trim link
      link = link.replace /^\s+|\s+$/g, ""

      #Add url prefix
      prefix = ''
      if ! link.match /(http|https|file|ftp):\/\//g
        prefix = 'http://'
      msg = msg.replace link, '<a href="' + prefix + link + '" target="_blank" rel="nofollow">' + link + '</a>'

  #Hash tag
  msg = msg.replace /\s?(\#([^ ]+)+)\s?/g, ' <a href="http://twitter.com/search?q=%23$2" target="_blank">$1</a> '

  #User tag
  msg.replace /\s?(\@([^ ]+)+)\s?/g, ' <a href="http://twitter.com/$2" target="_blank">$1</a> '
