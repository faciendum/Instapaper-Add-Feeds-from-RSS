#rss import to instapaper
#coded with love. faciendum.

class RssToInstapaper
  require "rss"
  require "open-uri"
  require "net/http"

  @instaUri = URI('https://www.instapaper.com/api/authenticate')
  @instapaperAddUrl = URI('https://www.instapaper.com/api/add')

  def self.sendFeedToInstapaper(url, user, password)

    unless url.nil? || url == ""
      begin
        puts "Validating rss..."
        open(url) do |rss|
          feed = RSS::Parser.parse(rss)
          puts "Found #{feed.channel.title} with #{feed.items.count} articles!"
          puts ""
          puts "Authenticate instapaper login..."

          Net::HTTP.start(@instaUri.host, @instaUri.port,
          :use_ssl => @instaUri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new @instaUri.request_uri
            request.basic_auth user, password
            response = http.request request

            if(response.body == "200")
              puts "Login worked!"
              puts "-------------"
              puts "Going to add those articles to your instapaper:"
              feed.items.each do |item|
                puts "Article: #{item.title}"
                #lets do the magic!
                Net::HTTP.post_form(@instapaperAddUrl,"username" => user, "password" =>password, "url" => "#{item.link}", "title" => "#{item.title}")
              end
            elsif(response.body == "403")
              puts "FAILED: Invalid username or password! Make sure your username and password are correct."
            end
            if(response.body == "500")
              puts "FAILED: The Instapaper service encountered an error. Please try again later."
            end
          end
        end
      rescue
        puts "FAILED: RSS url is null or empty or not a valid url. Check if your url doesn't have any bad characters and is accessable."
      end
    end
  end
end
RssToInstapaper.sendFeedToInstapaper(ARGV[0], ARGV[1], ARGV[2])
