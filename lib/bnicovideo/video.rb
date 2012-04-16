# coding: utf-8

# This file has video class.

require 'net/http'
require 'rexml/document'
require 'date'
require 'cgi'
require 'uri'

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
    # Download video
    # filename :: File name or stream. If nil, return binary
    def download(filename = nil)
      self.get_info
      return nil if @deleted
      resp = nil
      Net::HTTP.start('www.nicovideo.jp') do |http|
        resp = http.get('/watch/' + @video_id,
          {'Cookie' => 'user_session=' + @user_session.session_id})
      end
      adc = {}
      resp.each do |k, v|
        if k.downcase == 'set-cookie'
          z = v.split(';')
          z.map!{|cp| cp.gsub(/(^ +)|( +$)/, '')}
          hsh = {}
          z.each do |ckchr|
            ckchra = ckchr.split('=', 2)
            hsh[ckchra[0]] = ckchra[1]
          end
          hsh.each do |nk, nv|
            adc[nk] = nv unless ['expires', 'path', 'domain', 'secure'].include?(nk)
          end
        end
      end
      movie_url = access_getflv_api['url'][0]
      return if movie_url == nil
      resp3 = nil
      huri = URI.parse(movie_url)
      cks = {'user_session' => @user_session.session_id}.merge(adc)
      ckarr = []
      cks.each do |ckk, ckv|
        ckarr.push(ckk + '=' + ckv)
      end
      ckstr = ckarr.join('; ')
      Net::HTTP.start(huri.host) do |http|
        resp3 = http.get(huri.request_uri, {'Cookie' => ckstr})
      end
      return unless resp3.code.to_i == 200
      if filename == nil
        return resp3.body
      elsif filename.respond_to?(:write)
        filename.write(resp3.body)
      else
        File.open(filename, 'wb') do |file|
          file.write resp3.body
        end
      end
    end
    # Get comments
    def get_comments
      self.get_info
      return [] if @deleted
      hsh = access_getflv_api
      tid = hsh['thread_id'][0]
      return unless tid
      ms = hsh['ms'][0]
      uid = hsh['user_id'][0]
      req = '<packet><thread thread="' + tid + '" version="20090904" user_id="' +
        uid + '" score="1" /><thread_leaves thread="' + tid + '" user_id="' +
        uid + '" scores="1">0-' + ((@length + 59) / 60).to_s + ':100, 1000' +
        '</thread_leaves><thread thread="' + tid + '" version="20061206" ' +
        'res_from="-1000" fork="1" scores="1" /></packet>'
      uri = URI.parse(ms)
      resp = nil
      Net::HTTP.start(uri.host) do |http|
        resp = http.post(uri.request_uri, req,
          {'Cookie' => 'user_session=' + @user_session.session_id,
          'Content-Type' => 'application/xml'})
      end
      xml = REXML::Document.new(resp.body)
      ret = []
      xml.root.elements.each('chat') do |chn|
        comno = chn.attributes['no'].to_i
        vat = chn.attributes['vpos'].to_i / 100.0
        tat = Time.at(chn.attributes['date'].to_i)
        is184 = chn.attributes['anonymity'] == '1'
        user_id = chn.attributes['user_id']
        is_premium = chn.attributes['premium'] == '1'
        score = 0
        if chn.attributes['score']
          score = chn.attributes['score'].to_i
        end
        is_creator_comment = chn.attributes['fork'] == '1'
        ret.push({
          :comment_no => comno,
          :video_position => vat,
          :comment_at => tat,
          :anonymous? => is184,
          :user_id => user_id,
          :premium? => is_premium,
          :score => score,
          :creator_comment? => is_creator_comment
          })
      end
      return ret
    end
    # Access getflv API
    def access_getflv_api
      resp2 = nil
      Net::HTTP.start('flapi.nicovideo.jp') do |http|
        resp2 = http.get('/api/getflv/' + @video_id + '?as3=1',
          {'Cookie' => 'user_session=' + @user_session.session_id})
      end
      flvhsh = CGI.parse(resp2.body)
      return flvhsh
    end
  end
end
