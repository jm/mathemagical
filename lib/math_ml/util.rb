#!/usr/bin/ruby
#
# Utility for MathML Library
#
# Copyright (C) 2006, KURODA Hiraku <hiraku@hinet.mydns.jp>
# You can redistribute it and/or modify it under GPL2.
#

require "math_ml"

module MathML::Util
	ESCAPES = {"<"=>"lt",
		">"=>"gt",
		"&"=>"amp",
		"\""=>"quot",
		"'"=>"apos"
	}
	INVALID_RE = /(?!)/
	EQNARRAY_RE = /\\begin\s*\{eqnarray\}(#{MathML::LaTeX::MBEC}*?)\\end\s*\{eqnarray\}/
	SINGLE_COMMAND_RE = /(\\([a-zA-Z]+))[ \t]?/

	def self.escapeXML(s, br=false)
		r = s.gsub(/[<>&"']/){|m| "&#{ESCAPES[m]};"}
		br ? r.gsub(/\n/, "<br />\n") : r
	end

	def escapeXML(s, br=false)
		MathML::Util.escapeXML(s, br)
	end

	def self.collect_regexp(a)
		if a
			a = [a].flatten
			a.size>0 ? Regexp.new(a.inject(""){|r, i| i.is_a?(Regexp) ? "#{r}#{i.to_s}|" : r}.chop) : INVALID_RE
		else
			INVALID_RE
		end
	end

	def collect_regexp(a)
		MathML::Util.collect_regexp(a)
	end

	class MathData
		attr_reader :math_list, :msrc_list, :dmath_list, :dsrc_list, :escape_list, :esrc_list, :user_list, :usrc_list
		def initialize
			@math_list = []
			@msrc_list = []
			@dmath_list = []
			@dsrc_list = []
			@escape_list = []
			@esrc_list = []
			@user_list = []
			@usrc_list = []
		end

		def update(s)
			@math_list.concat(s.math_list)
			@msrc_list.concat(s.msrc_list)
			@dmath_list.concat(s.dmath_list)
			@dsrc_list.concat(s.dsrc_list)
			@escape_list.concat(s.escape_list)
			@esrc_list.concat(s.esrc_list)
			@user_list.concat(s.user_list)
			@usrc_list.concat(s.usrc_list)
		end
	end

	class SimpleLaTeX
		include MathML::Util
		@@default_latex = nil
		DEFAULT = {
			:delimiter=>"\001",
			:math_env_list=>[
				/\$((?:\\.|[^\\\$])#{MathML::LaTeX::MBEC}*?)\$/m,
				/\\\((#{MathML::LaTeX::MBEC}*?)\\\)/m
			],
			:dmath_env_list=>[
				/\$\$(#{MathML::LaTeX::MBEC}*?)\$\$/m,
				/\\\[(#{MathML::LaTeX::MBEC}*?)\\\]/m
			],
			:escape_list=>[
				/\\(.)/m
			],
			:through_list=>[
			],
			:escape_any=> false,
			:without_parse=>false
		}

		def initialize(options = {})
			@params = DEFAULT.merge(options)
			@params[:parser] = MathML::LaTeX::Parser.new unless @params[:parser] || @params[:without_parse]

			@params[:math_envs] = collect_regexp(@params[:math_env_list])
			@params[:dmath_envs] = collect_regexp(@params[:dmath_env_list])
			@params[:escapes] = collect_regexp(@params[:escape_list])
			@params[:throughs] = collect_regexp(@params[:through_list])
			reset_encode_proc
			reset_rescue_proc
			reset_decode_proc
			reset_unencode_proc
		end

		def reset_encode_proc
			@encode_proc_re = INVALID_RE
			@encode_proc = nil
		end

		def set_encode_proc(*re, &proc)
			@encode_proc_re = collect_regexp(re)
			@encode_proc = proc
		end

		def reset_rescue_proc
			@rescue_proc = nil
		end

		def set_rescue_proc(&proc)
			@rescue_proc = proc
		end

		def reset_decode_proc
			@decode_proc = nil
		end

		def set_decode_proc(&proc)
			@decode_proc = proc
		end

		def set_unencode_proc(&proc)
			@unencode_proc = proc
		end

		def reset_unencode_proc
			@unencode_proc = nil
		end

		def encode(src, *proc_re, &proc)
			if proc_re.size>0 && proc_re[0].is_a?(MathData)
				data = proc_re.shift
			else
				data = MathData.new
			end

			proc_re = proc_re.size==0 ? @encode_proc_re : collect_regexp(proc_re)
			proc = @encode_proc unless proc

			s = StringScanner.new(src)
			encoded = ""

			until s.eos?
				if s.scan(/(.*?)(((((#{@params[:throughs]})|#{@params[:dmath_envs]})|#{@params[:math_envs]})|#{proc_re})|#{@params[:escapes]})/m)
					encoded << s[1]
					case
					when s[6]
						encoded << s[6]
					when s[5], s[4]
						env_src = s[5] || s[4]
						if @params[:dmath_envs]=~env_src
							encoded << "#{@params[:delimiter]}d#{data.dsrc_list.size}#{@params[:delimiter]}"
							data.dsrc_list << env_src
						else
							encoded << "#{@params[:delimiter]}m#{data.msrc_list.size}#{@params[:delimiter]}"
							data.msrc_list << env_src
						end
					when s[3]
						size = s[3].size
						s.pos = left = s.pos-size
						if r=proc.call(s)
							right = s.pos
							encoded << "#{@params[:delimiter]}u#{data.user_list.size}#{@params[:delimiter]}"
							data.user_list << r
							data.usrc_list << s.string[left...right]
						else
							encoded << s.peek(size)
							s.pos = s.pos+size
						end
					when s[2]
						encoded << "#{@params[:delimiter]}e#{data.escape_list.size}#{@params[:delimiter]}"
						@params[:escapes]=~s[2]
						data.esrc_list << s[2]
						data.escape_list << escapeXML($+, true)
					end
				else
					encoded << s.rest
					s.terminate
				end
			end

			parse(data, @params[:parser]) unless @params[:without_parse]

			return encoded, data
		end

		def error_to_html(e)
			"<br />\n#{escapeXML(e.message)}<br />\n<code>#{escapeXML(e.done).gsub(/\n/, "<br />\n")}<strong>#{escapeXML(e.rest).gsub(/\n/, "<br />\n")}</strong></code><br />"
		end

		def latex_parser
			@params[:parser] = MathML::LaTeX::Parser.new unless @params[:parser]
			@params[:parser]
		end

		def parse(data, parser=nil)
			parser = latex_parser unless parser
			(data.math_list.size...data.msrc_list.size).each do |i|
				begin
					@params[:math_envs]=~data.msrc_list[i]
					data.math_list[i] = parser.parse($+)
				rescue MathML::LaTeX::ParseError => e
					if @rescue_proc
						data.math_list[i] = @rescue_proc.call(e)
					else
						data.math_list[i] = error_to_html(e)
					end
				end
			end
			(data.dmath_list.size...data.dsrc_list.size).each do |i|
				begin
					@params[:dmath_envs]=~data.dsrc_list[i]
					data.dmath_list[i] = parser.parse($+, true)
				rescue MathML::LaTeX::ParseError => e
					if @rescue_proc
						data.dmath_list[i] = @rescue_proc.call(e)
					else
						data.dmath_list[i] = error_to_html(e)
					end
				end
			end
		end

		def decode(encoded, data, without_parsed = false, &proc)
			return nil if encoded==nil
			proc = @decode_proc unless proc
			encoded.gsub(/#{Regexp.escape(@params[:delimiter])}([demu])(\d+)#{Regexp.escape(@params[:delimiter])}/) do
				i = $2.to_i
				t, d, s =
					case $1
					when "d"
						[:dmath, without_parsed ? escapeXML(data.dsrc_list[i], true) : data.dmath_list[i], data.dsrc_list[i]]
					when "e"
						[:escape, data.escape_list[i], data.esrc_list[i]]
					when "m"
						[:math, without_parsed ? escapeXML(data.msrc_list[i], true) : data.math_list[i], data.msrc_list[i]]
					when "u"
						[:user, data.user_list[i], data.usrc_list[i]]
					end
				if proc
					proc.call(d, :type=>t, :index=>i, :src=>s) || d
				else
					d
				end
			end
		end

		def decode_partial(type, encoded, data, &proc)
			return nil if encoded==nil
			head =
				case type
				when :math
					"m"
				when :dmath
					"d"
				when :escape
					"e"
				when :user
					"u"
				else
					return
				end
			encoded.gsub(/#{Regexp.escape(@params[:delimiter])}#{head}(\d+)#{Regexp.escape(@params[:delimiter])}/) do
				i = $1.to_i
				t, d, s =
					case head
					when "d"
						[:dmath, data.dmath_list[i], data.dsrc_list[i]]
					when "e"
						[:escape, data.escape_list[i], data.esrc_list[i]]
					when "m"
						[:math, data.math_list[i], data.msrc_list[i]]
					when "u"
						[:user, data.user_list[i], data.usrc_list[i]]
					end
				if proc
					proc.call(d, :type=>t, :index=>i, :src=>s) || "#{@params[:delimiter]}#{head}#{i}#{@params[:delimiter]}"
				else
					d
				end
			end
		end

		def unencode(encoded, data, without_escape=false, &proc)
			return nil if encoded==nil
			proc = @unencode_proc unless proc
			encoded.gsub(/#{Regexp.escape(@params[:delimiter])}([demu])(\d+)#{Regexp.escape(@params[:delimiter])}/) do
				i = $2.to_i
				t, s =
					case $1
					when "d"
						[:dmath, data.dsrc_list[i]]
					when "e"
						[:escape, data.esrc_list[i]]
					when "m"
						[:math, data.msrc_list[i]]
					when "u"
						[:user, data.usrc_list[i]]
					end
				s = escapeXML(s, true) unless without_escape
				if proc
					proc.call(s, :type=>t, :index=>i) || s
				else
					s
				end
			end
		end

		def self.encode(src)
			@@default_latex = self.new unless @@default_latex
			@@default_latex.encode(src)
		end

		def self.decode(src, data)
			@@default_latex.decode(src, data)
		end

		def parse_eqnarray(src, parser=nil)
			src = "\\begin{array}{ccc}#{src}\\end{array}"
			parser = latex_parser unless parser
			begin
				parser.parse(src, true)
			rescue MathML::LaTeX::ParseError => e
				e = MathML::LaTeX::ParseError.new(e.message,
					e.rest.sub(/\\end\{array\}\z/, '\end{eqnarray}'),
					e.done.sub(/\A\\begin\{array\}\{ccc\}/, '\begin{eqnarray}'))
				@rescue_proc ? @rescue_proc.call(e) : error_to_html(e)
			end
		end

		def parse_single_command(src, parser=nil)
			s = src[SINGLE_COMMAND_RE, 1]
			parser = latex_parser unless parser
			begin
				parser.parse(s)
			rescue MathML::LaTeX::ParseError => e
				src[SINGLE_COMMAND_RE, 2]
			end
		end
	end
end
