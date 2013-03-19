Tweets = new Meteor.Collection "tweets"

Template.tweets.latestTweet = ->
  Tweets.find({}, {limit: 10}) #Fetch tweets and limit the number to 10