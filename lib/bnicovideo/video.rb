# coding: utf-8

# This file has video class.

require 'net/http'
require 'rexml/document'
require 'date'

module Bnicovideo
  # This class represents video of Niconico Douga
  class Video
    # Video ID
    attr_reader :video_id
    # Video title
    attr_reader :title
    # Video description
    attr_reader :description
    # Thumbnail URL
    attr_reader :thumbnail_url
    # DateTime object when the video was post
    attr_reader :first_retrieve
    # Video length in seconds
    attr_reader :length
    # Movie type(mp4, flv, ...)
    attr_reader :movie_type
    # How many times this video was viewed
    attr_reader :view_counter
    # How many comments were post
    attr_reader :comment_num
    # How many mylists have this video
    attr_reader :mylist_counter
    # Embeddable this video
    attr_reader :embeddable
    # Whether this video can play in Niconico live streaming
    attr_reader :live_allowed
    # Tags' hash. Key is language and value is the array of Bnicovideo::Tag object.
    attr_reader :tags
    # User id of this video's author
    attr_reader :user_id
    # Whether this video was deleted
    attr_reader :deleted
    # Initialize from user session and video ID
    # user_session :: Bnicovideo::UserSession object
    # video_id :: Video ID
    def initialize(user_session, video_id)
      @user_session = user_session
      @video_id = video_id
      @info_got = false
    end
    # Get video information
    # refresh :: If this is set true, force get. Otherwise, get only if not gotten.
    def get_info(refresh = false)
      if @info_got && !refresh
        return
      end
      resp = nil
      Net::HTTP.start('ext.nicovideo.jp') do |http|
        resp = http.get('/api/getthumbinfo/' + @video_id,
          {'Cookie' => 'user_session=' + @user_session.session_id})
      end
      resp.value
      xml = REXML::Document.new(resp.body)
      root = xml.root
      if root.attributes['status'] == 'ok'
        @title = root.elements['thumb/title'].text
        @description = root.elements['thumb/description'].text
        @thumbnail_url = root.elements['thumb/thumbnail_url'].text
        @first_retrieve = DateTime.parse(root.elements['thumb/first_retrieve'].text)
        length_string = root.elements['thumb/length'].text
        length_arr = length_string.split(':')
        @length = length_arr[0].to_i * 60 + length_arr[1].to_i
        @movie_type = root.elements['thumb/movie_type'].text
        @view_counter = root.elements['thumb/view_counter'].text.to_i
        @comment_num = root.elements['thumb/comment_num'].text.to_i
        @mylist_counter = root.elements['thumb/mylist_counter'].text.to_i
        @embeddable = root.elements['thumb/embeddable'].text == '1'
        @live_allowed = root.elements['thumb/no_live_play'].text == '0'
        @tags = {}
        root.elements.each('thumb/tags') do |tse|
          key = tse.attributes['domain']
          dtags = []
          tse.elements.each('tag') do |tge|
            dtags.push(Bnicovideo::Tag.new(tge.text,
                tge.attributes['lock'] == '1', tge.attributes['category'] == '1'))
          end
          @tags[key] = dtags
        end
        @user_id = root.elements['thumb/user_id'].text
      else
        @deleted = true
      end
      @info_got = true
    end
  end
end
