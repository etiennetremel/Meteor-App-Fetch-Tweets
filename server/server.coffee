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
          date: tweet.created_at
          text: tweet.text
        }