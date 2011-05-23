require "rubygems"
require "bundler/setup"

require "mechanize"

class NokogiriParser < Mechanize::Page
  attr_reader :doc
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @doc = Nokogiri(body)
    super(uri, response, body, code)
  end
end

event_attendees_url = "http://lanyrd.com/2011/euruko/attendees"
event_name = "euruko-2011"

attendees = []
agent = Mechanize.new
agent.pluggable_parser.html = NokogiriParser
agent.get(event_attendees_url) do |page|
  (page/"ul.people li span:not(.name)").each do |span|
    attendees << span.inner_text.strip[1..-1]
  end
end

require "twitter"

config = YAML.load_file("config.yml")

Twitter.configure do |twitter|
  twitter.consumer_key = config[:consumer_key]
  twitter.consumer_secret = config[:consumer_secret]
  twitter.oauth_token = config[:oauth_token]
  twitter.oauth_token_secret = config[:oauth_token_secret]
end

Twitter.list_create(event_name)
Twitter.list_add_members(event_name, attendees)
