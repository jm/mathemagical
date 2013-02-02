#!/usr/bin/ruby
#
# Extension of String class by MathML Library
#
# Copyright (C) 2007, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2.
#

require "mathemagical"

module Mathemagical
	module String
		@@mathml_latex_parser = nil
		def self.mathml_latex_parser
			@@mathml_latex_parser = Mathemagical::LaTeX::Parser.new unless @@mathml_latex_parser
			@@mathml_latex_parser
		end

		def self.mathml_latex_parser=(mlp)
			raise TypeError unless mlp.is_a?(Mathemagical::LaTeX::Parser) || mlp==nil
			@@mathml_latex_parser = mlp
		end

		def to_mathml(displaystyle=false)
			Mathemagical::String.mathml_latex_parser.parse(self, displaystyle)
		end
	end
end

class String
	include Mathemagical::String
end
