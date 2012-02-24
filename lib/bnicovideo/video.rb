# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'rexml/document'

module Bnicovideo
  class Video
    attr_reader :video_id
    attr_reader :title
    attr_reader :description
    attr_reader :thumbnail_url
    attr_reader :first_retrieve
    attr_reader :length
    attr_reader :movie_type
    attr_reader :view_counter
    attr_reader :comment_num
    attr_reader :mylist_counter
    attr_reader :embeddable
    attr_reader :live_allowed
    attr_reader :tags
    attr_reader :user_id
    attr_reader :deleted
    def initialize(user_session, video_id)
      @user_session = user_session
      @video_id = video_id
      @info_got = false
    end
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
        @first_retrieve = root.elements['thumb/first_retrieve']
        length_string = root.elements['thumb/length'].text
        length_arr = length_string.split(':')
        @length = length_arr[0].to_i * 60 + length_arr[1].to_i
        @movie_type = root.elements['thumb/movie_type']
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
        @user_id = root.elements['user_id']
      else
        @deleted = true
      end
      @info_got = true
    end
  end
end
