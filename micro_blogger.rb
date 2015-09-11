require "jumpstart_auth"
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ''
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 'turl' then tweet(parts[1...-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def tweet(message)
		(message.size <= 140) ? @client.update(message) : (puts "too long, aborted")
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		puts message

		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		screen_names.include?(target) ? tweet("d @#{target} #{message}") : (puts "Error, no such follower")
	end

	def followers_list
		screen_names = Array.new 
		@client.followers.each {|follower| screen_names << @client.user(follower).screen_name}
		screen_names
	end

	def spam_my_followers(message)
		followers_list.each { |follower| dm(follower, message)}
	end

	def everyones_last_tweet
		friends = Array.new
		@client.followers.each {|follower| friends << @client.user(follower)}
		friends = friends.sort_by {|follower| follower.screen_name.downcase}

		friends.each do |follower|
			timestamp = follower.status.created_at
			name = @client.user(follower).screen_name
			last_tweet = @client.user(follower).status.text
			puts "On #{timestamp.strftime("%A, %b %d")}, #{name}, tweeted: #{last_tweet}"
		end
	end

	def shorten(original_url)
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		short_url = bitly.shorten(original_url).short_url
		puts "Shortening this URL: #{original_url}"
		short_url
	end
end

blogger = MicroBlogger.new
blogger.run