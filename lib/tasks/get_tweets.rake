namespace :twitter do
  desc "maintains our twitter feed"

  task get_tweets: :environment do
    puts 'FETCHING TWEETS...'
    begin
      results = CLIENT.search('@dreamt_in', {lang: "en", count: 2}).attrs[:statuses]
      tweets = results.map { |tweet| tweet[:text] }

      tweets = results.each do |tweet| 
        user = tweet[:user][:screen_name] 
        city = tweet[:text].split(' ')[1..-1].join(' ')
        Tweet.find_or_create_by(username: user, city: city)
      end
      puts 'SUCCESS'
    rescue
      puts 'ERROR'
    end
  end

  task respond_to_tweets: :environment do
    puts 'CRAFTING RESPONSES...'
    begin
      respond = Tweet.where(tweet: nil)
      respond.each do |tweet|
        send = HaikuEngine.haiku_time(tweet.username, tweet.city)
        Tweet.post_tweet(send)
        tweet.update_attributes(tweet: send)
      end
    rescue
      puts 'ERROR'
    end
  end
end