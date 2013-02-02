# MathML Library
#
# Copyright (C) 2005, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2.

require "strscan"
require "htmlentities"

module MathML
	class Error < StandardError; end

	# Borrowed from eim_xml.rb
	def self.encode(s)
  	# s.to_s.gsub(/[&\"\'<>]/) do |m|
   #  	case m
   #  	when "&"
   #  		"&amp;"
   #  	when '"'
   #  		"&quot;"
   #  	when "'"
   #  		"&apos;"
   #  	when "<"
   #  		"&lt;"
   #  	when ">"
   #  		"&gt;"
   #  	end
   #  end
    @entities ||= HTMLEntities.new
    # TODO: HTMLEntities Y U DOUBLE ENCODE??
    @entities.encode(s).gsub(/&amp;([#a-zA-Z0-9]{2,24});/, '&\1;')
  end
end

require "math_ml/element"
require "math_ml/symbol/entity_reference"
require "math_ml/latex"
