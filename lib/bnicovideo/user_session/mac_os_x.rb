# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rexml/document'
require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  module UserSession
    class MacOsX
      def self.init_from_firefox
        base_path = File.join(ENV['HOME'], 'Library', 'Application Support', 'Firefox')
        ini_path = File.join(base_path, 'profiles.ini')
        ini_hash = IniFile.load(ini_path).to_h
        profile_path = nil
        ini_hash.each do |k, v|
          next unless v['Name'] == 'default'
          relative = (v['IsRelative'] != '0')
          input_path = v['Path']
          if relative
            profile_path = File.join(base_path, input_path)
          else
            profile_path = input_path
          end
          sql_path = File.join(profile_path, 'cookies.sqlite')
          conn = SQLite3::Database.new(sql_path)
          val = conn.get_first_value("select value from moz_cookies" +
              " where host='.nicovideo.jp' AND name='user_session'")
          return val
        end
        return nil
      end
      def self.init_from_chrome
        sql_path = File.join(ENV['HOME'], 'Library', 'Application Support',
          'Google', 'Chrome', 'Default', 'Cookies')
        conn = SQLite3::Database.new(sql_path)
        val = conn.get_first_value("select value from cookies" +
            " where host_key='.nicovideo.jp' AND name='user_session'")
        conn.close
        return val
      end
      def self.init_from_safari
        cookie_base_path = File.join(ENV['HOME'], 'Library', 'Cookies')
        bcpath = File.join(cookie_base_path, 'Cookies.binarycookies')
        if File.exist?(bcpath)
          cookie_path = bcpath
          bin = nil
          File.open(cookie_path, 'rb') do |file|
            bin = file.read
          end
          raise 'Invalid Cookie file' unless bin[0..3] == 'cook'
          page_num = bin[4..7].unpack('N')[0]
          pages_length = []
          page_num.times do |i|
            page_length = bin[(8 + i * 4)..(11 + i * 4)].unpack('N')[0]
            pages_length.push(page_length)
          end
          read_ptr = 8 + page_num * 4
          pages_length.each do |pgl|
            page = bin[read_ptr..(read_ptr + pgl - 1)]
            cookies_num = page[4..7].unpack('V')[0]
            nread_ptr = read_ptr
            cookies_offset = []
            cookies_num.length.times do |i|
              cookie_offset = page[(8 + i * 4)..(11 + i * 4)].unpack('V')[0]
              cookies_offset.push(cookie_offset)
            end
            nread_ptr += 12 + cookies_num * 4
            read_ptr += pgl
            cookies_offset.each do |cof|
              cookie_length = page[cof..(cof + 3)].unpack('V')[0]
              cookie_bin = page[cof..(cof + cookie_length - 1)]
              offset_url = page[(cof + 16)..(cof + 19)].unpack('V')[0]
              offset_name = page[(cof + 20)..(cof + 23)].unpack('V')[0]
              offset_path = page[(cof + 24)..(cof + 27)].unpack('V')[0]
              offset_value = page[(cof + 28)..(cof + 31)].unpack('V')[0]
              url_end = (/\x00/ =~ cookie_bin[offset_url..-1])
              url = cookie_bin[offset_url, url_end]
              name_end = (/\x00/ =~ cookie_bin[offset_name..-1])
              name = cookie_bin[offset_name, name_end]
              path_end = (/\x00/ =~ cookie_bin[offset_path..-1])
              path = cookie_bin[offset_path, path_end]
              value_end = (/\x00/ =~ cookie_bin[offset_value..-1])
              value = cookie_bin[offset_value, value_end]
              return value if (/nicovideo\.jp$/ =~ url) && (name == 'user_session')
            end
          end
          return nil
        else
          xml = REXML::Document.new(File.read)
          xml.root.elements.each('array/dict') do |elem|
            if elem.elements['key[text()="Domain"]'] &&
                elem.elements['key[text()="Domain"]'].next_sibling &&
                elem.elements['key[text()="Domain"]'].next_sibling.text == '.nicovideo.jp' &&
                elem.elements['key[text()="Name"]'] &&
                elem.elements['key[text()="Name"]'].next_sibling &&
                elem.elements['key[text()="Name"]'].next_sibling.text == 'user_session'
              return elem.elements['key[text()="Value"]'].next_sibling.text
            end
          end
          return nil
        end
      end
    end
  end
end
