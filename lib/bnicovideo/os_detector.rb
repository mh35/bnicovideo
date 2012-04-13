# To change this template, choose Tools | Templates
# and open the template in the editor.

module Bnicovideo
  module OsDetector
    def self.detect
      if /mswin(?!ce)|mingw|cygwin|bccwin/ =~ RUBY_PLATFORM
        # Windows
        return Bnicovideo::WindowsDetector.check
      elsif /darwin/ =~ RUBY_PLATFORM
        return 'macosx'
      elsif /java/ =~ RUBY_PLATFORM
        # JRuby
        os_name = Java::JavaLang::System.getProperty('os.name')
        if /Windows/ =~ os_name
          os_version = Java::JavaLang::System.getProperty('os.version')
          mj = os_version.split('.')[0]
          if mj == '6'
            return 'winvista'
          elsif mj == '5'
            return 'winxp'
          else
            return 'win95'
          end
        elsif /Mac OS X/ =~ os_name
          return 'macosx'
        else
          return 'unix'
        end
      else
        return 'unix'
      end
    end
  end
end
