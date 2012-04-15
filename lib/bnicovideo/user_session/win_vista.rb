# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  class UserSession
    # Windows Vista and 7
    module WinVista
      # Get user session from Firefox(3.0 or later)
      def self.init_from_firefox
        ini_path = File.join(ENV['APPDATA'], 'Mozilla', 'Firefox', 'profiles.ini')
        ini_hash = IniFile.load(ini_path).to_h
        profile_path = nil
        ini_hash.each do |k, v|
          next unless v['Name'] == 'default'
          relative = (v['IsRelative'] != '0')
          input_path = v['Path']
          if relative
            profile_path = File.join(ENV['APPDATA'], 'Mozilla', 'Firefox', input_path)
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
      # Get user session from Google Chrome
      def self.init_from_chrome
        sql_path = File.join(ENV['LOCALAPPDATA'], 'Google','Chrome', 'User Data', 'Default', 'Cookies')
        conn = SQLite3::Database.new(sql_path)
        val = conn.get_first_value("select value from cookies" +
            " where host_key='.nicovideo.jp' AND name='user_session'")
        conn.close
        return val
      end
      # Get user session from Internet Explorer
      def self.init_from_ie
        cookies_path = File.join(ENV['APPDATA'], 'Microsoft', 'Windows', 'Cookies', 'Low')
        Dir.open(cookies_path) do |dir|
          dir.each do |fn|
            next unless (/.*@nicovideo.*/ =~ fn)
            File.open(fn) do |f|
              cb = f.read
              cs = cb.split(/\*\n/)
              cs.each do |c|
                ca = c.split(/\n/)
                return ca[1] if ca[0] == 'user_session'
              end
            end
          end
        end
        return nil
      end
      # Get user session from Safari
      def self.init_from_safari
        cookie_path = File.join(ENV['APPDATA'], 'Apple Computer', 'Safari',
          'Cookies', 'Cookies.binarycookies')
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
          cookies_num.times do |i|
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
      end
    end
  end
end
