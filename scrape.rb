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


def participants_for_event(url, kind)
  attendees = []
  agent = Mechanize.new
  agent.pluggable_parser.html = NokogiriParser
  agent.get(url + "/" + kind) do |page|
    (page/"ul.people li span:not(.name)").each do |span|
      attendees << span.inner_text.strip[1..-1]
    end
  end
  attendees
end

def ensure_twitter_list(name)
  puts "Ensuring list %p exists" % name
  Twitter.list(name)
rescue Twitter::NotFound
  Twitter.list_create(name)
end

def ensure_twitter_list_members(name, attendees)
  puts "Ensuring #{attendees.length} members for list %p" % name
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

def list_name(name, type)
  [name, type].map { |s| s.downcase.gsub(" ", "-") }.join("-")
end

def ensure_list(event_url, type)
  list = list_name(event_name(event_url), type)
  ensure_twitter_list(list)
  ensure_twitter_list_members(list, participants_for_event(event_url, type))
end

def process_event(url)
  ensure_list(url, "attendees")
  ensure_list(url, "speakers")
end

process_event "http://lanyrd.com/2011/euruko"