require "sinatra"
require "open-uri"
require "nokogiri"

set :bind, "0.0.0.0"
set :port, 3000

get "/" do
  url = "https://" + params["url"]
  html = Nokogiri::HTML(open(url))
  title = html.xpath("//head//title").first.text

  title
end

run Sinatra::Application.run!
