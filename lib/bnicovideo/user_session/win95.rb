# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  class UserSession
    # Windows 95 and NT 4.x
    module Win95
      def self.init_from_firefox
        # Single user only
        base_path = File.join(ENV['windir'], 'Application Data', 'Mozilla', 'Firefox')
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
      def self.init_from_ie
        cookies_path = File.join(ENV['windir'], 'Cookie')
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
    end
  end
end
