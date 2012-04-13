# This file has the top level of module

# Top level module of bnicovideo gem.
module Bnicovideo
  autoload :Mylist, File.join(File.dirname(__FILE__), 'bnicovideo', 'mylist.rb')
  autoload :Tag, File.join(File.dirname(__FILE__), 'bnicovideo', 'tag.rb')
  autoload :UserSession, File.join(File.dirname(__FILE__), 'bnicovideo', 'user_session.rb')
  autoload :Video, File.join(File.dirname(__FILE__), 'bnicovideo', 'video.rb')
  autoload :OsDetector, File.join(File.dirname(__FILE__), 'bnicovideo', 'os_detector.rb')
  autoload :WindowsDetector, File.join(File.dirname(__FILE__), 'bnicovideo', 'windows_detector.rb')
end
