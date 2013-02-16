# MathML Library
#
# Copyright (C) 2005, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2.

require "strscan"
require "htmlentities"

module Mathemagical
  VERSION = '0.0.2' unless defined?(:VERSION)

	class Error < StandardError; end

	def self.encode(s)
    @entities ||= HTMLEntities.new

    # TODO: HTMLEntities Y U DOUBLE ENCODE??
    @entities.encode(s).gsub(/&amp;([#a-zA-Z0-9]{2,24});/, '&\1;')
  end
end

require "mathemagical/element"
require "mathemagical/symbol/entity_reference"
require "mathemagical/latex"
