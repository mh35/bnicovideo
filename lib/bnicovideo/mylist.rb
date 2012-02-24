# coding: utf-8

# This file is mylist class file

require 'rexml/document'
require 'uri'
require 'net/http'

module Bnicovideo
  # Mylist class
  class Mylist
    # Mylist ID
    attr_reader :mylist_id
    # Videos' hash. Video key is Bnicovideo::Video class object, and Content key is mylist description.
    attr_reader :videos
    # Mylist title
    attr_reader :title
    # Mylist description
    attr_reader :subtitle
    # Mylist author
    attr_reader :author
    # Init from user session and mylist ID
    # user_session :: Bnicovideo::UserSession
    # mylist_id :: Mylist ID
    def initialize(user_session, mylist_id)
      @got = false
      @user_session = user_session
      @mylist_id = mylist_id
    end
    # Force read information
    def read!
      @videos = []
      resp = nil
      Net::HTTP.start('www.nicovideo.jp') do |http|
        resp = http.get('/mylist/' + @mylist_id.to_s + '?rss=atom',
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
    # Read information
    # refresh :: If this is true, force read. Otherwise, read unless not read.
    def read(refresh = false)
      return if @got && !refresh
      read!
    end
  end
end
