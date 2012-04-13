# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  class UserSession
    module Linux
      def self.init_from_firefox
        base_path = File.join(ENV['HOME'], '.mozilla', 'firefox')
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
        sql_path = File.join(ENV['HOME'], '.config', 'google-chrome', 'Default', 'Cookies')
        conn = SQLite3::Database.new(sql_path)
        val = conn.get_first_value("select value from cookies" +
            " where host_key='.nicovideo.jp' AND name='user_session'")
        conn.close
        return val
      end
    end
  end
end
