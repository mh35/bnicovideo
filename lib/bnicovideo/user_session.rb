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
  end
end
