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
        cookie_path = File.join(profile_path, 'cookies.sqlite')
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
  end
end
