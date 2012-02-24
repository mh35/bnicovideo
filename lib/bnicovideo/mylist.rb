# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rexml/document'
require 'uri'

module Bnicovideo
  class Mylist
    attr_reader :mylist_id
    attr_reader :videos
    attr_reader :title
    attr_reader :subtitle
    attr_reader :author
    def initialize(user_session, mylist_id)
      @got = false
      @user_session = user_session
      @mylist_id = mylist_id
    end
    def read!
      @videos = []
      resp = nil
      Net::HTTP.start('www.nicovideo.jp') do |http|
        resp = http.get('/mylist' + @mylist_id + '?rss=atom',
          {'Cookie' => 'user_session=' + @user_session.session_id})
      end
      resp.value
      xml = REXML::Document.new(resp.body)
      root = xml.root
      @title = root.elements['title'].text
      @subtitle = root.elements['subtitle'].text
      @author = root.elements['author/name'].text
      root.elements.each('entry') do |entry|
        video_link = entry.elements['link'].attributes['href']
        uri = URI.parse(video_link)
        next unless uri.scheme == 'http' && uri.host == 'www.nicovideo.jp'
        video_id = uri.path.split('/')[-1]
        @videos.push({
            'Video' => Bnicovideo::Video.new(@user_session, video_id),
            'Content' => entry.elements['content'].text
          })
      end
      @got = true
    end
    def read(refresh = false)
      return if @got && !refresh
      read!
    end
  end
end
