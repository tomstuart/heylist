require "rubygems"
require "mechanize"
require "nokogiri"

class NokogiriParser < Mechanize::Page
  attr_reader :doc
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @doc = Nokogiri(body)
    super(uri, response, body, code)
  end
end

agent = Mechanize.new
agent.pluggable_parser.html = NokogiriParser
agent.get("http://lanyrd.com/2011/euruko/attendees") do |page|
  (page/"ul.people li span:not(.name)").each do |span|
    puts span.inner_text.strip
  end
end