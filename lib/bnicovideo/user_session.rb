# coding: utf-8

# This file has user session class.

require 'rubygems'
require 'sqlite3'
require 'inifile'

module Bnicovideo
  # User session class
  class UserSession
    autoload :Win95, File.join(File.dirname(__FILE__), 'user_session', 'win95.rb')
    autoload :WinXp, File.join(File.dirname(__FILE__), 'user_session', 'win_xp.rb')
    autoload :WinVista, File.join(File.dirname(__FILE__), 'user_session', 'win_vista.rb')
    autoload :MacOsX, File.join(File.dirname(__FILE__), 'user_session', 'mac_os_x.rb')
    autoload :Linux, File.join(File.dirname(__FILE__), 'user_session', 'linux.rb')
    OS_LIST = {'winvista' => WinVista, 'winxp' => WinXp, 'win95' => Win95,
      'macosx' => MacOsX, 'unix' => Linux
    }
    # User session ID
    attr_reader :session_id
    def initialize(sid)
      @session_id = sid
    end
    # Get user session from Firefox(3.0 or later)
    def self.init_from_firefox
      sess = OS_LIST[Bnicovideo::OsDetector.detect].init_from_firefox
      if sess
        return self.new(sess)
      else
        return nil
      end
    end
    # Get user session from Google Chrome
    def self.init_from_chrome
      sess = OS_LIST[Bnicovideo::OsDetector.detect].init_from_chrome
      if sess
        return self.new(sess)
      else
        return nil
      end
    end
    # Get user session from Internet Explorer
    def self.init_from_ie
      sess = OS_LIST[Bnicovideo::OsDetector.detect].init_from_ie
      if sess
        return self.new(sess)
      else
        return nil
      end
    end
    # Get user session from Safari
    def self.init_from_safari
      sess = OS_LIST[Bnicovideo::OsDetector.detect].init_from_safari
      if sess
        return self.new(sess)
      else
        return nil
      end
    end
  end
end
