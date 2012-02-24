# To change this template, choose Tools | Templates
# and open the template in the editor.

module Bnicovideo
  class Tag
    attr_reader :name
    attr_reader :locked
    attr_reader :category
    def initialize(name, locked = false, category = false)
      @name = name
      @locked = locked
      @category = category
    end
  end
end
