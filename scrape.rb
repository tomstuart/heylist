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
  agent.get(url + "/attendees") do |page|
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

def event_name(url)
  name = nil
  agent = Mechanize.new
  agent.pluggable_parser.html = NokogiriParser
  agent.get(url) do |page|
    (page/"h1.summary").each do |h1|
      name = h1.inner_text
    end
  end
  name
end

def list_name(name)
  name.downcase.gsub(" ", "-")
end

event_url = "http://lanyrd.com/2011/euruko"

list = list_name(event_name(event_url))
ensure_list(list)
ensure_list_members(list, attendees_for_event(event_url))