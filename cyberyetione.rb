#!/usr/bin/env ruby
# vim: ts=2 sts=2 et
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'json'
require 'yaml'
# general

config = YAML.load_file('cyberyeti.config')
post_uris = config[:cannoncam_uri].map do |x|
    URI(x)
end

uri = URI('https://hooks.slack.com/services/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')

# random
# https://hooks.slack.com/services/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

webcam_noko = Nokogiri::XML(Net::HTTP.get(URI('https://www.cannonmt.com/mountain/webcam-daily-photo')))

picture_url = webcam_noko.xpath('//div[@class="panel-foreground panel-video"]/img').first['src']
picture_uri = 'https://www.cannonmt.com/' + picture_url

yeti_post = {
    blocks: [
        {
            type: 'image',
            title: {
                type: 'plain_text',
                text: 'Yeti Cave Status'
            },
            image_url: picture_uri,
            alt_text: 'Cannon Cam'
        }
    ]
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
