# coding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sqlite3'

module Bnicovideo
  class UserSession
    def initialize(sid)
      @session_id = sid
    end
    def self.init_from_firefox
      ini_path = File.join(ENV['APPDATA'], 'Mozilla', 'Firefox', 'profiles.ini')
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
