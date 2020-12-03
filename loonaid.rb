#!/usr/bin/env ruby
# frozen_string_literal: true

# vim: ts=2 sts=2 et
# Ski snow report for Loon Mountain. Schedule with cron.
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'json'
require 'html2text'
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), '/cyberyeti.config'))

post_uris = config[:slack_channels].map do |x|
  URI(x)
end

mountain_report_noko = Nokogiri::HTML(Net::HTTP.get(URI('https://www.loonmtn.com/conditions')))

report_text = mountain_report_noko.xpath('//div[@class="quarantine" and @data-module="quarantine"]').first.inner_html
report_text.lstrip!
report_text.gsub!('<b>', '*')
report_text.gsub!('</b>', "*\r\n")
conditions = [{
  type: 'section',
  text: {
    type: 'mrkdwn',
    text: "LOON SKI REPORT.\r\nHope it snows and the Jerrys don't come."
  },
  accessory: {
    type: 'image',
    image_url: 'https://media.giphy.com/media/q1DIVOS5BcF6o/giphy.gif',
    alt_text: 'i do this'
  }
}]

conditions.push(
  {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: Html2Text.convert(report_text)
    }
  }
)

conditions.push( { type: 'divider' } )
conditions.push(
  {
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: 'Grab the Loon live camera here: https://www.youtube.com/watch?v=zlwbkP1WGp8'
    }
  }
)

yeti_post = {
  blocks: conditions
}

post_uris.each do |uri|
  req = Net::HTTP::Post.new(uri, 'Content-type' => 'application/json', 'User-Agent' => 'Curl')
  req.body = yeti_post.to_json
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  res = http.request(req)
  puts res.inspect
  puts yeti_post.to_json
end
