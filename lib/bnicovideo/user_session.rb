# coding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  class UserSession
    def initialize(sid)
      @session_id = sid
    end
    def self.init_from_firefox
      ini_path = File.join(ENV['APPDATA'], 'Mozilla', 'Firefox', 'profiles.ini')
      ini_hash = IniFile.load(ini_path)
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
        return self.new(val)
      end
    end
    def self.init_from_chrome
      sql_path = File.join(ENV['LOCALAPPDATA'], 'Google','Chrome', 'User Data', 'Default', 'Cookies')
      conn = SQLite3::Database.new(sql_path)
      val = conn.get_first_value("select value from cookies" +
          " where host_key='.nicovideo.jp' AND name='user_session'")
      conn.close
      return self.new(val)
    end
    def self.init_from_ie
      cookies_path = File.join(ENV['APPDATA'], 'Microsoft', 'Windows', 'Cookies', 'Low')
    end
    def self.init_from_opera
      cookie_path = File.join(ENV['APPDATA'], 'Opera', 'Opera', 'profile', 'cookies4.dat')
    end
    def self.init_from_safari
      cookie_path = File.join(ENV['APPDATA'], 'Apple Computer', 'Safari',
        'Cookies', 'Cookies.binarycookies')
      raise NotImplementedError, 'I don\'t know how to resolve ' + cookie_path
    end
  end
end
