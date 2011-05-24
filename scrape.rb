require "rubygems"
require "bundler/setup"

require "mechanize"
require "twitter"

class NokogiriParser < Mechanize::Page
  attr_reader :doc
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @doc = Nokogiri(body)
    super(uri, response, body, code)
  end
end

config = YAML.load_file("config.yml")

Twitter.configure do |twitter|
  twitter.consumer_key = config[:consumer_key]
  twitter.consumer_secret = config[:consumer_secret]
  twitter.oauth_token = config[:oauth_token]
  twitter.oauth_token_secret = config[:oauth_token_secret]
end



def attendees_for_event(url)
  attendees = []
  agent = Mechanize.new
  agent.pluggable_parser.html = NokogiriParser
  agent.get(url) do |page|
    (page/"ul.people li span:not(.name)").each do |span|
      attendees << span.inner_text.strip[1..-1]
    end
  end
  attendees
end

def ensure_list(name)
  puts "Ensuring list %p exists" % name
  Twitter.list(name)
rescue Twitter::NotFound
  Twitter.list_create(name)
end

def ensure_list_members(name, attendees)
  puts "Ensuring #{attendees.length} attendees for list %p" % name
  Twitter.list_add_members(name, attendees)
end


event_attendees_url = "http://lanyrd.com/2011/euruko/attendees"
event_name = "euruko-2011"

ensure_list(event_name)
ensure_list_members(event_name, attendees_for_event(event_attendees_url))