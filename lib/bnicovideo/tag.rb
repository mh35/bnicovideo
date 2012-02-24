# coding: utf-8

# This file has Niconico Douga tag class.

module Bnicovideo
  # The tag class
  class Tag
    # Tag name
    attr_reader :name
    # True if tag is locked
    attr_reader :locked
    # True if tag is the category tag
    attr_reader :category
    # Initialize from name, locked and whether this tag is category.
    # name :: Tag name
    # locked :: Whether this tag is locked
    # category :: Whether this tag is the category tag.
    def initialize(name, locked = false, category = false)
      @name = name
      @locked = locked
      @category = category
    end
  end
end
