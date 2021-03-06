#!/usr/bin/env ruby
# frozen_string_literal: true

# vim: ts=2 sts=2 et
# Ski snow report for Cannon Mountain. Schedule with cron.
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

mountain_report_noko = Nokogiri::XML(Net::HTTP.get(URI('https://www.cannonmt.com/mountain-report')))

primary = mountain_report_noko.xpath('//div[@id="data-primary-surface"]/div').first.text
secondary = mountain_report_noko.xpath('//div[@id="data-secondary-surface"]/div').first.text

forecast_summary = mountain_report_noko.xpath('//div[@id="forecast-summary"]').first.text
lo_temp = mountain_report_noko.xpath('//div[@id="today"]/div[@class="data-temp"]/div[@class="datum"]')[0].text.sub('Low', '')
hi_temp = mountain_report_noko.xpath('///div[@id="today"]/div[@class="data-temp"]/div[@class="datum"]')[1].text.sub('High', '')

base_wind = mountain_report_noko.xpath('//div[@id="today"]/div[@class="data-wind"]/div')[0].text.tr(' ', '').tr("\n", ' ')
summit_wind = mountain_report_noko.xpath('//div[@id="today"]/div[@class="data-wind"]/div')[1].text.tr(' ', '').tr("\n", ' ')

conditions = [{
  type: 'section',
  text: {
    type: 'mrkdwn',
    text: "CANNON MOUTAIN SKI REPORT\r\nTime for your daily coolaid report."
  },
  accessory: {
    type: 'image',
    image_url: 'https://media.giphy.com/media/VRa3YCyi3JSWk/giphy.gif',
    alt_text: 'OOHHHhHHH Yeeeaaahhhh!!!'
  }
}]

conditions.append(mountain_report_noko.xpath('//div[@id="conditions"]/p')[0, 3].map do |x|
  [{
    type: 'section',
    text: {
      type: 'plain_text',
      text: Html2Text.convert(x)
    }
  },
   {
     "type": 'divider'
   }]
end)
conditions.flatten!

conditions.push(
  type: 'section',
  text: {
    type: 'mrkdwn',
    text: "*SNOW CONDITION LIES*\n"\
        "*PRIMARY:* #{primary} (but probably ice)\n"\
        "*SECONDARY:* #{secondary} (but probably ice)\n"
  }
)
conditions.push(type: 'divider')
conditions.push(
  type: 'section',
  text: {
    type: 'mrkdwn',
    text: "*WEATHER LIES*\n"\
        "*FORECAST:* #{forecast_summary}\n"\
        "*LOW:* #{lo_temp} (but probably -5)\n"\
        "*HIGH:* #{hi_temp} (but probably 10)\n"\
        "*BASE WIND:* #{base_wind}\n"\
        "*SUMMIT WIND:* #{summit_wind}\n"
  }
)
conditions.push(type: 'divider')
conditions.push(
  type: 'section',
  text: {
    type: 'mrkdwn',
    text: 'find more at https://www.cannonmt.com/mountain-report'
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
