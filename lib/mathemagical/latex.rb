require "mathemagical/latex/builtin"

module Mathemagical
	module LaTeX
		MBEC = /\\.|[^\\]/m

		module RE
			SPACE = /(?:\s|%.*$)/
			NUMERICS = /(?:\.\d+)|(?:\d+(\.\d+)?)/
			OPERATORS = /[,\.\+\-\*=\/\(\)\[\]<>"|;:!]/
			ALPHABETS = /[a-zA-Z]/
			BLOCK = /\A\{(.*?)\}\z/m
			OPTION = /\A\[(.*)\]\z/m
			COMMANDS = /\\([a-zA-Z]+|[^a-zA-Z])/
			WBSLASH = /\\\\/
			BRACES = /\A([.|\[\]\(\)<>])\z/
		end

		module Font
			NORMAL = 0
			BOLD = 1
			BLACKBOLD = 2
			SCRIPT = 3
			FRAKTUR = 4
			ROMAN = 5
			BOLD_ITALIC = 6
		end

		class BlockNotClosed < StandardError; end
		class NotEnvironment < StandardError; end
		class EnvironmentNotEnd < StandardError; end
		class NeedParameter < StandardError; end
		class EndMismatchToBegin < StandardError; end
		class OptionNotClosed < StandardError; end

		class Scanner < StringScanner
			def done
				self.string[0, pos]
			end

			def scan_space
				_scan(/#{RE::SPACE}+/)
			end

			def skip_space_and(check_mode)
				opos = pos
				scan_space
				r = yield
				self.pos = opos if check_mode || !r
				r
			end

			unless instance_methods.include?("_eos?")
				alias :_eos? :eos?
				alias :_check :check
				alias :_scan :scan
			end

			def check(re)
				skip_space_and(true){_check(re)}
			end

			def scan(re)
				skip_space_and(false){_scan(re)}
			end

			def eos?
				_eos? || _check(/#{RE::SPACE}+\z/)
			end

			def check_command
				check(RE::COMMANDS)
			end

			def scan_command
				scan(RE::COMMANDS)
			end

			def peek_command
				check_command ? self[1] : nil
			end

			def check_block
				skip_space_and(true){scan_block}
			end

			def scan_block
				return nil unless scan(/\{/)
				block = "{"
				bpos = pos-1
				nest = 1
				while _scan(/(#{MBEC}*?)([\{\}])/)
					block << matched
					case self[2]
					when "{"
						nest+=1
					when "}"
						nest-=1
						break if nest==0
					end
				end
				if nest>0
					self.pos = bpos
					raise BlockNotClosed
				end
				self.pos = bpos
				_scan(/\A\{(#{Regexp.escape(block[RE::BLOCK, 1].to_s)})\}/)
			end

			def check_any(remain_space=false)
				skip_space_and(true){scan_any(remain_space)}
			end

			def scan_any(remain_space=false)
				p = pos
				scan_space
				r = remain_space ? matched.to_s : ""
				case
				when s = scan_block
				when s = scan_command
				else
					unless _scan(/./) || remain_space
						self.pos = p
						return nil
					end
					s = matched.to_s
				end
				r << s
			end

			def scan_option
				return nil unless scan(/\[/)
				opt = "["
				p = pos-1
				until (s=scan_any(true)) =~ /\A#{RE::SPACE}*\]\z/
					opt << s
					if eos?
						self.pos = p
						raise OptionNotClosed
					end
				end
				opt << s
				self.pos = p
				_scan(/\A\[(#{Regexp.escape(opt[RE::OPTION, 1].to_s)})\]/)
			end

			def check_option
				skip_space_and(true){scan_option}
			end
		end

		class ParseError < StandardError
			attr_accessor :rest, :done
			def initialize(message, rest = "", done = "")
				@done = done
				@rest = rest
				super(message)
			end

			def inspect
				"#{message} : '#{@done}' / '#{@rest}'\n"+backtrace[0..5].join("\n")
			end
		end

		class Macro
			class Command
				attr_reader :num, :body, :option
				def initialize(n, b, o)
					@num = n
					@body = b
					@option = o
				end
			end

			class Environment
				attr_reader :num, :beginning, :ending, :option
				def initialize(n, b, e, o)
					@num = n
					@beginning = b
					@ending = e
					@option = o
				end
			end

			def initialize
				@commands = Hash.new
				@environments = Hash.new
			end

			def parse_error(message, rest="", whole=nil)
				rest = whole[/\A.*?(#{Regexp.escape(rest)}.*\z)/, 1] if whole
				rest << @scanner.rest
				done = @scanner.string[0, @scanner.string.size-rest.size]
				ParseError.new(message, rest, done)
			end

			def parse(src)
				@scanner = Scanner.new(src)
				until @scanner.eos?
					unless @scanner.scan_command
						@scanner.scan_space
						raise parse_error("Syntax error.")
					end
					case @scanner[1]
					when "newcommand"
						parse_newcommand
					when "newenvironment"
						parse_newenvironment
					else
						raise parse_error("Syntax error.", @scanner.matched)
					end
				end
			rescue BlockNotClosed => e
				raise parse_error("Block not closed.")
			rescue OptionNotClosed => e
				raise parse_error("Option not closed.")
			end

			def scan_num_of_parameter
				if @scanner.scan_option
					raise parse_error("Need positive number.", @scanner[1]+"]") unless @scanner[1]=~/\A#{RE::SPACE}*\d+#{RE::SPACE}*\z/
					@scanner[1].to_i
				else
					0
				end
			end

			def check_parameter_numbers(src, opt, whole)
				s = Scanner.new(src)
				until s.eos?
					case
					when s.scan(/#{MBEC}*?\#(\d+|.)/)
						raise parse_error("Need positive number.") unless s[1]=~/\d+/
						raise parse_error("Parameter \# too large.", s[1]+s.rest, whole) if s[1].to_i>opt
					else
						return nil
					end
				end
			end

			def parse_newcommand
				case
				when @scanner.scan_block
					s = Scanner.new(@scanner[1])
					raise parse_error("Need newcommand.", s.rest+"}") unless s.scan_command
					com = s[1]
					raise parse_error("Syntax error." ,s.rest+"}") unless s.eos?
				when @scanner.scan_command
					s = Scanner.new(@scanner[1])
					com = s.scan_command
				else
					raise parse_error("Need newcommand.")
				end

				optnum = scan_num_of_parameter
				opt = @scanner.scan_option ? @scanner[1] : nil

				case
				when @scanner.scan_block
					body = @scanner[1]
				when @scanner.scan_command
					body = @scanner.matched
				else
					body = @scanner.scan(/./)
				end

				raise parse_error("Need parameter.") unless body

				check_parameter_numbers(body, optnum, @scanner.matched)

				optnum-=1 if opt
				@commands[com] = Command.new(optnum, body, opt)
			end

			def parse_newenvironment
				case
				when @scanner.scan_block
					env = @scanner[1]
				when @scanner.scan_command
					raise ParseError.new
				when @scanner.scan(/./)
					env = @scanner.matched
				end
				raise parse_error("Syntax error.", env[/\A.*?(\\.*\z)/, 1], @scanner.matched) if env=~/\\/

				optnum = scan_num_of_parameter
				opt = @scanner.scan_option ? @scanner[1] : nil

				b = @scanner.scan_block ? @scanner[1] : @scanner.scan_any
				raise parse_error("Need begin block.") unless b
				check_parameter_numbers(b, optnum, @scanner.matched)
				e = @scanner.scan_block ? @scanner[1] : @scanner.scan_any
				raise parse_error("Need end block.") unless e
				check_parameter_numbers(e, optnum, @scanner.matched)

				optnum -= 1 if opt
				@environments[env] = Environment.new(optnum, b, e, opt)
			end

			def commands(com)
				@commands[com]
			end

			def expand_command(com, params, opt=nil)
				return nil unless @commands.has_key?(com)
				c = @commands[com]
				opt = c.option if c.option && !opt
				params.unshift(opt) if c.option
				raise ParseError.new("Need more parameter.") if params.size < c.num

				c.body.gsub(/(#{MBEC}*?)\#(\d+)/) do
					$1.to_s << params[$2.to_i-1]
				end
			end

			def environments(env)
				@environments[env]
			end

			def expand_environment(env, body, params, opt=nil)
				return nil unless @environments.has_key?(env)
				e = @environments[env]
				opt = e.option if e.option && !opt
				params.unshift(opt) if e.option
				raise ParseError.new("Need more parameter.") if params.size < e.num

				bg = e.beginning.gsub(/(#{MBEC}*?)\#(\d+)/) do
					$1.to_s << params[$2.to_i-1]
				end

				en = e.ending.gsub(/(#{MBEC}*?)\#(\d+)/) do
					$1.to_s << params[$2.to_i-1]
				end

				" #{bg} #{body} #{en} "
			end
		end

		module BuiltinCommands; end
		module BuiltinGroups; end
		module BuiltinEnvironments; end

		class Parser
			class CircularReferenceCommand < StandardError; end

			include LaTeX

			include BuiltinEnvironments
			include BuiltinGroups
			include BuiltinCommands

			BUILTIN_MACRO = <<'EOS'
\newenvironment{smallmatrix}{\begin{matrix}}{\end{matrix}}
\newenvironment{pmatrix}{\left(\begin{matrix}}{\end{matrix}\right)}
\newenvironment{bmatrix}{\left[\begin{matrix}}{\end{matrix}\right]}
\newenvironment{Bmatrix}{\left\{\begin{matrix}}{\end{matrix}\right\}}
\newenvironment{vmatrix}{\left|\begin{matrix}}{\end{matrix}\right|}
\newenvironment{Vmatrix}{\left\|\begin{matrix}}{\end{matrix}\right\|}
EOS

			attr_accessor :unsecure_entity
			attr_reader :macro
			attr_reader :symbol_table

			def initialize(opt={})
				@unsecure_entity = false
				@entities = Hash.new
				@commands = Hash.new
				@symbols = Hash.new
				@delimiters = Array.new
				@group_begins = Hash.new
				@group_ends = Hash.new
				@macro = Macro.new
				@macro.parse(BUILTIN_MACRO)
				@expanded_command = Array.new
				@expanded_environment = Array.new
				@symbol_table = opt[:symbol] || Mathemagical::Symbol::Default
				@symbol_table = Mathemagical::Symbol::MAP[@symbol_table] if @symbol_table.is_a?(::Symbol)

				super()
			end

			def add_entity(list)
				list.each do |i|
					@entities[i] = true
				end
			end

			def parse(src, displaystyle=false)
				@ds = displaystyle
				@math = Math.new(@ds)
				begin
					parse_into(src, @math, Font::NORMAL)
				rescue ParseError => e
					e.done = src[0...(src.size - e.rest.size)]
					raise
				end
			end

			def push_container(container, scanner=@scanner, font=@font)
				data = [@container, @scanner, @font]
				@container, @scanner, @font = [container, scanner, font]
				begin
					yield container
					container
				ensure
					@container, @scanner, @font = data
				end
			end

			def add_plugin(plugin)
				self.extend(plugin)
			end

			def add_commands(*a)
				if a.size==1 && Hash===a[0]
					@commands.merge!(a[0])
				else
					a.each{|i| @commands[i] = false}
				end
			end

			def add_multi_command(m, *a)
				a.each{|i| @commands[i] = m}
			end

			def add_sym_cmd(hash)
				@symbols.merge!(hash)
			end

			def add_delimiter(list)
				@delimiters.concat(list)
			end

			def add_group(begin_name, end_name, method=nil)
				@group_begins[begin_name] = method
				@group_ends[end_name] = begin_name
			end

			private
			def parse_into(src, parent, font=nil)
				orig = [@scanner, @container, @font, @ds]
				@scanner = Scanner.new(src)
				@container = parent
				@font = font if font
				begin
					until @scanner.eos?
						@container << parse_to_element(true)
					end
					@container
				rescue BlockNotClosed => e
					raise  ParseError.new("Block not closed.", @scanner.rest)
				rescue NotEnvironment => e
					raise ParseError.new("Not environment.", @scanner.rest)
				rescue EnvironmentNotEnd => e
					raise ParseError.new("Environment not end.", @scanner.rest)
				rescue OptionNotClosed => e
					raise ParseError.new("Option not closed.", @scanner.rest)
				rescue ParseError => e
					e.rest << @scanner.rest.to_s
					raise
				ensure
					@scanner, @container, @font, @ds = orig
				end
			end

			def parse_any(message = "Syntax error.")
				raise ParseError.new(message) unless @scanner.scan_any
				s = @scanner
				@scanner = Scanner.new(@scanner.matched)
				begin
					parse_to_element
				ensure
					@scanner = s
				end
			end

			def parse_to_element(whole_group = false)
				if whole_group && @group_begins.has_key?(@scanner.peek_command)
					@scanner.scan_command
					parse_group
				else
					case
					when @scanner.scan(RE::NUMERICS)
						parse_num
					when @scanner.scan(RE::ALPHABETS)
						parse_char
					when @scanner.scan(RE::OPERATORS)
						parse_operator
					when @scanner.scan_block
						parse_block
					when @scanner.scan(/_/)
						parse_sub
					when @scanner.scan(/'+|\^/)
						parse_sup
					when @scanner.scan(/~/)
						Space.new("1em")
					when @scanner.scan_command
						parse_command
					else
						raise ParseError.new('Syntax error.')
					end
				end
			end

			def parse_num
				n = Number.new
				n.extend(Variant).variant = Variant::BOLD if @font==Font::BOLD
				n << @scanner.matched
			end

			def parse_char
				c = @scanner.matched
				i = Identifier.new
				case @font
				when Font::ROMAN
					i.extend(Variant).variant = Variant::NORMAL
				when Font::BOLD
					i.extend(Variant).variant = Variant::BOLD
				when Font::BOLD_ITALIC
					i.extend(Variant).variant = Variant::BOLD_ITALIC
				when Font::BLACKBOLD
					c = symbol_table.convert("#{c}opf")
				when Font::SCRIPT
					c = symbol_table.convert("#{c}scr")
				when Font::FRAKTUR
					c = symbol_table.convert("#{c}fr")
				end
				i << c
			end

			def parse_operator
				o = @scanner.matched
				Operator.new.tap{|op| op[:stretchy]="false"} << o
			end

			def parse_block
				os = @scanner
				@scanner =  Scanner.new(@scanner[1])
				begin
					push_container(Row.new) do |r|
						r << parse_to_element(true) until @scanner.eos?
					end
				rescue ParseError => e
					e.rest << '}'
					raise
				ensure
					@scanner = os
				end
			end

			def parse_sub
				e = @container.pop
				e = None.new unless e
				e = SubSup.new(@ds && e.display_style, e) unless e.is_a?(SubSup)
				raise ParseError.new("Double subscript.", "_") if e.sub
				e.sub = parse_any("Subscript not exist.")
				e
			end

			def parse_sup
				e = @container.pop
				e = None.new unless e
				e = SubSup.new(@ds && e.display_style, e) unless e.is_a?(SubSup)
				raise ParseError.new("Double superscript.", @scanner[0]) if e.sup
				if /'+/=~@scanner[0]
					prime = Operator.new
					@scanner[0].size.times do
						prime << symbol_table.convert("prime")
					end
					unless @scanner.scan(/\^/)
						e.sup = prime
						return e
					end
				end
				sup = parse_any("Superscript not exist.")

				if prime
					unless sup.is_a?(Row)
						r = Row.new
						r << sup
						sup = r
					end
					sup.children.insert(0, prime)
				end

				e.sup = sup
				e
			end

			def entitize(str)
				Mathemagical.encode(str.sub(/^(.*)$/){"&#{$1};"})
			end

			def parse_symbol_command(com, plain=false)
				unless @symbols.include?(com)
					@scanner.pos = @scanner.pos-(com.size+1)
					raise ParseError.new("Undefined command: #{com}")
				end
				data = @symbols[com]
				return nil unless data

				data, s = data
				su = data[0]
				el = data[1]
				el = :o unless el
				s = com.dup.untaint.to_sym unless s
				s = com if s.is_a?(String) && s.length==0

				case el
				when :I
					el = Identifier.new
				when :i
					el = Identifier.new
					el.extend(Variant).variant = Variant::NORMAL unless s.is_a?(String)&&s.length>1
				when :o
					el = Operator.new
					el[:stretchy] = "false"
				when :n
					el = Number.new
				else
					raise ParseError.new("Inner data broken.")
				end

				case s
				when Fixnum
					s = Mathemagical.encode("&\#x#{s.to_s(16)};")
				when ::Symbol
					s = symbol_table.convert(s)
				else
					Mathemagical.encode(s)
				end

				return s if plain
				el << s
				el.as_display_style if su==:u
				el
			end

			def parse_command
				com = @scanner[1]
				matched = @scanner.matched
				pos = @scanner.pos-matched.size
				macro = @macro.commands(com)
				if macro
					begin
						flg = @expanded_command.include?(com)
						@expanded_command.push(com)
						raise CircularReferenceCommand if flg
						option = (macro.option && @scanner.scan_option) ? @scanner[1] : nil
						params = Array.new
						(1..macro.num).each do
							params << (@scanner.scan_block ? @scanner[1] : @scanner.scan_any)
							raise ParseError.new("Need more parameter.") unless params.last
						end
						r = parse_into(@macro.expand_command(com, params, option), Array.new)
						return r
					rescue CircularReferenceCommand
						if @expanded_command.size>1
							raise
						else
							@scanner.pos = pos
							raise ParseError.new("Circular reference.")
						end
					rescue ParseError => e
						if @expanded_command.size>1
							raise
						else
							@scanner.pos = pos
							raise ParseError.new(%[Error in macro(#{e.message} "#{e.rest.strip}").])
						end
					ensure
						@expanded_command.pop
					end
				elsif @commands.key?(com)
					m = @commands[com]
					m = com unless m
					return __send__("cmd_#{m.to_s}")
				end
				parse_symbol_command(com)
			end

			def parse_mathfont(font)
				f = @font
				@font = font
				begin
					push_container(Row.new){|r| r << parse_any}
				ensure
					@font = f
				end
			end

			def parse_group
				font = @font
				begin
					g = @group_begins[@scanner[1]]
					g = @scanner[1] unless g
					__send__("grp_#{g.to_s}")
				ensure
					@font = font
				end
			end
		end

		module BuiltinCommands
			OVERS = {'hat'=>'circ', 'breve'=>'smile', 'grave'=>'grave',
				'acute'=>'acute', 'dot'=>'sdot', 'ddot'=>'nldr', 'dddot'=>'mldr', 'tilde'=>'tilde',
				'bar'=>'macr', 'vec'=>'rightarrow', 'check'=>'vee', 'widehat'=>'circ',
				'overline'=>'macr', 'widetilde'=>'tilde', 'overbrace'=>'OverBrace'}
			UNDERS = {'underbrace'=>'UnderBrace', 'underline'=>'macr'}

			def initialize
				add_commands("\\"=>:backslash)
				add_commands("entity", "stackrel", "frac", "sqrt", "mbox")
				add_multi_command(:hat_etc, *OVERS.keys)
				add_multi_command(:underbrace_etc, *UNDERS.keys)
				add_multi_command(:quad_etc, " ", "quad", "qquad", ",", ":", ";", "!")
				add_multi_command(:it_etc, "it", "rm", "bf")
				add_multi_command(:mathit_etc, "mathit", "mathrm", "mathbf", "bm", "mathbb", "mathscr", "mathfrak")
				add_sym_cmd(Builtin::Symbol::MAP)
				add_delimiter(Builtin::Symbol::DELIMITERS)

				super
			end

			def cmd_backslash
				@ds ? nil : Break.new
			end

			def cmd_hat_etc
				com = @scanner[1]
				Over.new(parse_any, Operator.new << entitize(OVERS[com]))
			end

			def cmd_underbrace_etc
				com = @scanner[1]
				Under.new(parse_any, Operator.new << entitize(UNDERS[com]))
			end

			def cmd_entity
				param = @scanner.scan_block ? @scanner[1] : @scanner.scan(/./)
				raise ParseError.new("Need parameter.") unless param
				unless @unsecure_entity || @entities[param]
					param =@scanner.matched[/\A\{#{RE::SPACE}*(.*\})\z/, 1] if @scanner.matched=~RE::BLOCK
					@scanner.pos = @scanner.pos-(param.size)
					raise ParseError.new("Unregistered entity.")
				end
				Operator.new << entitize(param)
			end

			def cmd_stackrel
				o = parse_any; b = parse_any
				Over.new(b, o)
			end

			def cmd_quad_etc
				case @scanner[1]
				when ' '
					Space.new("1em")
				when 'quad'
					Space.new("1em")
				when 'qquad'
					Space.new("2em")
				when ','
					Space.new("0.167em")
				when ':'
					Space.new("0.222em")
				when ';'
					Space.new("0.278em")
				when '!'
					Space.new("-0.167em")
				end
			end

			def cmd_it_etc
				case @scanner[1]
				when 'it'
					@font = Font::NORMAL
				when 'rm'
					@font = Font::ROMAN
				when 'bf'
					@font = Font::BOLD
				end
				nil
			end

			def cmd_mathit_etc
				case @scanner[1]
				when 'mathit'
					parse_mathfont(Font::NORMAL)
				when 'mathrm'
					parse_mathfont(Font::ROMAN)
				when 'mathbf'
					parse_mathfont(Font::BOLD)
				when 'bm'
					parse_mathfont(Font::BOLD_ITALIC)
				when 'mathbb'
					parse_mathfont(Font::BLACKBOLD)
				when 'mathscr'
					parse_mathfont(Font::SCRIPT)
				when 'mathfrak'
					parse_mathfont(Font::FRAKTUR)
				end
			end

			def cmd_frac
				n = parse_any; d = parse_any
				Frac.new(n, d)
			end

			def cmd_sqrt
				if @scanner.scan_option
					i = parse_into(@scanner[1], Array.new)
					i = i.size==1 ? i[0] : (Row.new << i)
					b = parse_any
					Root.new(i, b)
				else
					Sqrt.new << parse_any
				end
			end

			def cmd_mbox
				@scanner.scan_any
				Text.new << (@scanner.matched =~ RE::BLOCK ? @scanner[1] : @scanner.matched)
			end
		end

		module BuiltinGroups
			class CircularReferenceEnvironment < StandardError; end

			def initialize
				add_group("begin", "end")
				add_group("left", "right", :left_etc)
				add_group("bigg", "bigg", :left_etc)
				@environments = Hash.new

				super
			end

			def add_environment(*a)
				@environments = Hash.new unless @environments
				if a.size==1 && Hash===a[0]
					@environments.merge!(hash)
				else
					a.each{|i| @environments[i] = false}
				end
			end

			def grp_begin
				matched = @scanner.matched
				begin_pos = @scanner.pos-matched.size
				en = @scanner.scan_block ? @scanner[1] : @scanner.scan_any
				raise ParseError.new('Environment name not exist.') unless en

				macro = @macro.environments(en)
				if macro
					begin
						flg = @expanded_environment.include?(en)
						@expanded_environment.push(en)
						raise CircularReferenceEnvironment if flg

						pos = @scanner.pos
						option = (macro.option && @scanner.scan_option) ? @scanner[1] : nil
						params = Array.new
						(1..macro.num).each do
							params << (@scanner.scan_block ? @scanner[1] : @scanner.scan_any)
							raise ParseError.new("Need more parameter.") unless params.last
						end
						body = ""
						grpnest = 0
						until @scanner.peek_command=="end" && grpnest==0
							if @scanner.eos?
								@scanner.pos = pos
								raise ParseError.new('Matching \end not exist.')
							end
							com = @scanner.peek_command
							grpnest += 1 if @group_begins.has_key?(com)
							grpnest -=1 if @group_ends.has_key?(com) && @group_begins[com]
							raise ParseError.new("Syntax error.") if grpnest<0

							body << @scanner.scan_any(true)
						end
						@scanner.scan_command
						raise ParseError.new("Environment mismatched.", @scanner.matched) unless en==(@scanner.scan_block ? @scanner[1] : @scanner.scan_any)
						begin
							return parse_into(@macro.expand_environment(en, body, params, option), Array.new)
						rescue CircularReferenceEnvironment
							if @expanded_environment.size>1
								raise
							else
								@scanner.pos = begin_pos
								raise ParseError.new("Circular reference.")
							end
						rescue ParseError => e
							if @expanded_environment.size>1
								raise
							else
								@scanner.pos = begin_pos
								raise ParseError.new(%[Error in macro(#{e.message} "#{e.rest.strip}").])
							end
						end
					ensure
						@expanded_environment.pop
					end
				end

				raise ParseError.new("Undefined environment.") unless @environments.has_key?(en)
				e = @environments[en]
				e = en unless e # default method name

				__send__("env_#{e.to_s}")
			end

			def grp_left_etc
				right =
					case @scanner[1]
					when "left"
						"right"
					when "bigg"
						"bigg"
					end

				f = Fenced.new
				p = @scanner.pos
				o = @scanner.scan_any
				raise ParseError.new('Need brace here.') unless o && (o=~RE::BRACES || @delimiters.include?(o[RE::COMMANDS, 1]))
				f.open = (o=~RE::BRACES ? o : parse_symbol_command(o[RE::COMMANDS, 1], true))
				f << push_container(Row.new) do |r|
					until @scanner.peek_command==right
						if @scanner.eos?
							@scanner.pos = p
							raise ParseError.new('Brace not closed.')
						end
						r << parse_to_element(true)
					end
				end
				@scanner.scan_command # skip right
				c = @scanner.scan_any
				raise ParseError.new('Need brace here.') unless c=~RE::BRACES || @delimiters.include?(c[RE::COMMANDS, 1])
				f.close = (c=~RE::BRACES ? c : parse_symbol_command(c[RE::COMMANDS, 1], true))
				f
			end
		end

		module BuiltinEnvironments
			def initialize
				add_environment("array", "matrix", "equation")

				super
			end

			def env_equation
				until @scanner.peek_command=="end"
					raise ParseError.new('Matching \end not exist.') if @scanner.eos?

					push_container(@math) do |e|
						e << parse_to_element(true) until @scanner.peek_command=="end" || @scanner.eos?
					end
				end

				raise ParseError.new("Need \\end{equation}.") unless @scanner.peek_command=="end"
				@scanner.scan_command
				raise ParseError.new("Environment mismatched.") unless @scanner.check_block && @scanner[1]=="equation"
				@scanner.scan_block
			end

			def env_array
				layout = @scanner.scan_block ? @scanner.matched : @scanner.scan(/./)
				l = Scanner.new(layout=~RE::BLOCK ? layout[RE::BLOCK, 1] : layout)
				t = Table.new
				aligns = Array.new
				vlines = Array.new
				vlined = l.check(/\|/)
				columned = false
				until l.eos?
					c = l.scan_any
					raise ParseError.new("Syntax error.", layout[/\A.*(#{Regexp.escape(c+l.rest)}.*\z)/m, 1]) unless c=~/[clr\|@]/

					if c=='|'
						aligns << Align::CENTER if vlined
						vlines << Line::SOLID
						vlined = true
						columned = false
					else
						vlines << Line::NONE if columned
						vlined = false
						columned = true
						case c
						when 'l'
							aligns << Align::LEFT
						when 'c'
							aligns << Align::CENTER
						when 'r'
							aligns << Align::RIGHT
						when '@'
							aligns << Align::CENTER
							l.scan_any
						end
					end
				end
				t.aligns = aligns
				t.vlines = vlines

				layout = layout[RE::BLOCK, 1] if layout=~RE::BLOCK
				raise ParseError.new('Need parameter here.') if layout==""

				hlines = Array.new
				row_parsed = false
				hlined = false
				until @scanner.peek_command=="end"
					raise ParseError.new('Matching \end not exist.') if @scanner.eos?
					if @scanner.peek_command=="hline"
						@scanner.scan_command
						t << Tr.new unless row_parsed
						hlines << Line::SOLID
						row_parsed = false
						hlined = true
					else
						hlines << Line::NONE if row_parsed
						t << env_array_row(l.string)
						@scanner.scan(RE::WBSLASH)
						row_parsed = true
						hlined = false
					end
				end
				t.hlines = hlines

				if hlined
					tr = Tr.new
					(0..vlines.size).each {|i| tr << Td.new}
					t << tr
				end

				@scanner.scan_command
				raise ParseError.new("Environment mismatched.") unless @scanner.check_block && @scanner[1]=="array"
				@scanner.scan_block
				t
			end

			def env_array_row(layout)
				l = Scanner.new(layout)
				r = Tr.new
				first_column = true
				vlined = l.check(/\|/)
				until l.eos?
					c = l.scan(/./)
					if c=='|'
						r << Td.new if vlined
						vlined = true
						next
					else
						vlined = false
						case c
						when 'r', 'l', 'c'
						when '@'
							r << parse_into(l.scan_any, Td.new)
							next
						end
						if first_column
							first_column = false
						else
							raise ParseError.new("Need more column.", @scanner.matched.to_s) unless @scanner.scan(/&/)
						end
						r << push_container(Td.new) do |td|
							td << parse_to_element(true) until @scanner.peek_command=="end" || @scanner.check(/(&|\\\\)/) || @scanner.eos?
						end
					end
				end
				r << Td.new if vlined
				raise ParseError.new("Too many column.") if @scanner.check(/&/)
				r
			end

			def env_matrix
				t = Table.new
				hlines = Array.new
				hlined = false
				row_parsed = false
				until @scanner.peek_command=="end"
					raise ParseError.new('Matching \end not exist.') if @scanner.eos?
					if @scanner.peek_command=="hline"
						@scanner.scan_command
						t << Tr.new unless row_parsed
						hlines << Line::SOLID
						row_parsed = false
						hlined = true
					else
						hlines << Line::NONE if row_parsed
						t << (r = Tr.new)
						r << (td=Td.new)
						until @scanner.check(RE::WBSLASH) || @scanner.peek_command=="end" || @scanner.eos?
							push_container(td) do |e|
								e << parse_to_element(true) until @scanner.peek_command=="end" || @scanner.check(/(&|\\\\)/) || @scanner.eos?
							end
							r << (td=Td.new) if @scanner.scan(/&/)
						end
						@scanner.scan(RE::WBSLASH)
						row_parsed = true
						hlined = false
					end
				end
				t.hlines = hlines

				t << Tr.new if hlined

				raise ParseError.new("Need \\end{array}.") unless @scanner.peek_command=="end"
				@scanner.scan_command
				raise ParseError.new("Environment mismatched.") unless @scanner.check_block && @scanner[1]=="matrix"
				@scanner.scan_block
				t
			end

			def env_matrix_row
				r = Tr.new
				until @scanner.check(RE::WBSLASH) || @scanner.peek_command=="end"
					r << push_container(Td.new) do |td|
						td << parse_to_element(true) until @scanner.peek_command=="end" || @scanner.check(/(&|\\\\)/) || @scanner.eos?
					end
				end
			end
		end
	end
end
