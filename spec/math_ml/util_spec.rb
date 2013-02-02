require "mathemagical/util"

describe Mathemagical::Util do
	include Mathemagical::Util

	it "#escapeXML" do
		escapeXML("<>&\"'").should == "&lt;&gt;&amp;&quot;&apos;"
		escapeXML("\n").should == "\n"
		escapeXML("\n", true).should == "<br />\n"
	end

	it ".escapeXML" do
		Mathemagical::Util.escapeXML("<>&\"'").should == "&lt;&gt;&amp;&quot;&apos;"
		Mathemagical::Util.escapeXML("\n").should == "\n"
		Mathemagical::Util.escapeXML("\n", true).should == "<br />\n"
	end

	it "#collect_regexp" do
		collect_regexp([/a/, /b/, /c/]).should == /#{/a/}|#{/b/}|#{/c/}/
		collect_regexp([[/a/, /b/, /c/]]).should == /#{/a/}|#{/b/}|#{/c/}/
		collect_regexp([]).should == /(?!)/
		collect_regexp(/a/).should == /#{/a/}/
	end

	it ".collect_regexp" do
		Mathemagical::Util.collect_regexp([/a/, /b/, /c/]).should == /#{/a/}|#{/b/}|#{/c/}/
		Mathemagical::Util.collect_regexp([[/a/, /b/, /c/]]).should == /#{/a/}|#{/b/}|#{/c/}/
		Mathemagical::Util.collect_regexp([]).should == /(?!)/
		Mathemagical::Util.collect_regexp(/a/).should == /#{/a/}/

		Mathemagical::Util.collect_regexp([nil, /a/, "text", /b/]).should == /#{/a/}|#{/b/}/

		Mathemagical::Util.collect_regexp([nil, [/a/, [/b/, /c/]]]).should == /#{/a/}|#{/b/}|#{/c/}/
	end

	it "::INVALID_RE" do
		Mathemagical::Util::INVALID_RE.should == /(?!)/
	end
end

describe Mathemagical::Util::MathData do
	it "#<< and #update" do
		m = Mathemagical::Util::MathData.new
		m.math_list << "ml1"
		m.msrc_list << "sl1"
		m.dmath_list << "dml1"
		m.dsrc_list << "dsl1"
		m.escape_list << "el1"
		m.esrc_list << "es1"
		m.user_list << "ul1"
		m.usrc_list << "usl1"
		m.math_list.should == ["ml1"]
		m.msrc_list.should == ["sl1"]
		m.dmath_list.should == ["dml1"]
		m.dsrc_list.should == ["dsl1"]
		m.escape_list.should == ["el1"]
		m.esrc_list.should == ["es1"]
		m.user_list.should == ["ul1"]
		m.usrc_list.should == ["usl1"]

		m2 = Mathemagical::Util::MathData.new
		m2.math_list << "ml2"
		m2.msrc_list << "sl2"
		m2.dmath_list << "dml2"
		m2.dsrc_list << "dsl2"
		m2.escape_list << "el2"
		m2.esrc_list << "es2"
		m2.user_list << "ul2"
		m2.usrc_list << "usl2"

		m.update(m2)

		m.math_list.should == ["ml1", "ml2"]
		m.msrc_list.should == ["sl1",  "sl2"]
		m.dmath_list.should == ["dml1", "dml2"]
		m.dsrc_list.should == ["dsl1", "dsl2"]
		m.escape_list.should == ["el1", "el2"]
		m.esrc_list.should == ["es1", "es2"]
		m.user_list.should == ["ul1", "ul2"]
		m.usrc_list.should == ["usl1", "usl2"]
	end
end

describe Mathemagical::Util::SimpleLaTeX do
	def strip_math(s)
		s.gsub(/>\s*/, ">").gsub(/\s*</, "<")[/<math.*?>(.*)<\/math>/m, 1]
	end

	def sma(a) # Stripped Mathml Array
		r = []
		a.each do |i|
			r << strip_math(i.to_s)
		end
		r
	end

	def simplify_math(src)
		attr = []
		r = src.gsub(/<math(\s+[^>]+)>/) do |m|
			attr << $1.scan(/\s+[^\s]+/).map{|i| i[/\A\s*(.*)/, 1]}.sort
			"<math>"
		end
		attr.unshift(r)
	end

	def assert_data(src,
			expected_math, expected_src,
			expected_dmath, expected_dsrc,
			expected_escaped, expected_esrc,
			expected_encoded, expected_decoded,
			simple_latex = Mathemagical::Util::SimpleLaTeX)
		encoded, data = simple_latex.encode(src)

		data.math_list.each do |i|
			i.attributes[:display].should == "inline"
		end
		data.dmath_list.each do |i|
			i.attributes[:display].should == "block"
		end

		sma(data.math_list).should == expected_math
		data.msrc_list.should == expected_src
		sma(data.dmath_list).should == expected_dmath
		data.dsrc_list.should == expected_dsrc
		data.escape_list.should == expected_escaped
		data.esrc_list.should == expected_esrc
		encoded.should == expected_encoded
		target = simple_latex.decode(encoded, data)
		simplify_math(target).should == simplify_math(expected_decoded)
	end

	it "(spec for helper)" do
		simplify_math("<math c='d' a='b'>..</math><math g='h' e='f'></math>").should == ["<math>..</math><math></math>", %w[a='b' c='d'], %w[e='f' g='h']]
	end

	it "should parse math environment" do
		assert_data("a\n$\nb\n$\nc\\(\nd\n\\)e",
			["<mi>b</mi>", "<mi>d</mi>"],
			["$\nb\n$", "\\(\nd\n\\)"],
			[], [], [], [],
			"a\n\001m0\001\nc\001m1\001e",
			"a\n<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>\nc<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>d</mi></math>e")

		assert_data('$\\$$',
			["<mo stretchy='false'>$</mo>"],
			['$\$$'], [], [], [], [], "\001m0\001",
			"<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mo stretchy='false'>$</mo></math>")
	end

	it "should parse dmath environment" do
		assert_data("a\n$$\nb\n$$\nc\\[\nd\n\\]e",
			[], [],
			["<mi>b</mi>", "<mi>d</mi>"],
			["$$\nb\n$$", "\\[\nd\n\\]"],
			[], [],
			"a\n\001d0\001\nc\001d1\001e",
			"a\n<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>\nc<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>d</mi></math>e")
	end

	it "should parse math and dmath environment" do
		assert_data('a$b$c$$d$$e\(f\)g\[h\]i',
			["<mi>b</mi>", "<mi>f</mi>"],
			["$b$", '\(f\)'],
			["<mi>d</mi>", "<mi>h</mi>"],
			["$$d$$", '\[h\]'],
			[], [],
			"a\001m0\001c\001d0\001e\001m1\001g\001d1\001i",
			"a<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>c<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>d</mi></math>e<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>f</mi></math>g<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>h</mi></math>i")
	end

	it "should parse escaping" do
		assert_data('a\bc\d\e', [], [], [], [], ['b', 'd', 'e'], ['\b', '\d', '\e'], "a\001e0\001c\001e1\001\001e2\001", 'abcde')
		assert_data('\$a$$b$$', [], [], ["<mi>b</mi>"], ["$$b$$"], [%[$]], ['\$'], "\001e0\001a\001d0\001",
			"$a<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>")

		assert_data("\\<\\\n", [], [], [], [], ["&lt;", "<br />\n"], ["\\<", "\\\n"], "\001e0\001\001e1\001", "&lt;<br />\n")
	end

	it "should accept through_list option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:through_list=>[/\{\{.*\}\}/, /\(.*\)/])
		assert_data("{{$a$}}($b$)", [], [], [], [], [], [], "{{$a$}}($b$)", "{{$a$}}($b$)", s)

		s = Mathemagical::Util::SimpleLaTeX.new(:through_list=>/\{.*\}/)
		assert_data("{$a$}", [], [], [], [], [], [], "{$a$}", "{$a$}", s)
	end

	it "should accept parser option" do
		ps = Mathemagical::LaTeX::Parser.new
		ps.macro.parse('\newcommand{\test}{t}')
		s = Mathemagical::Util::SimpleLaTeX.new(:parser=>ps)
		assert_data('$\test$', ["<mi>t</mi>"], ['$\test$'], [], [], [], [], "\001m0\001",
			"<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>t</mi></math>", s)
	end

	it "should accept escape option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:escape_list=>[/\/(.)/, /(\^.)/])
		assert_data('\$a$', ["<mi>a</mi>"], ['$a$'], [], [], [], [], "\\\001m0\001",
			"\\<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math>", s)
		assert_data(%[/$a/$], [], [], [], [], [%[$], %[$]], [%[/$], %[/$]], "\001e0\001a\001e1\001", "$a$", s)
		assert_data('^\(a^\)', [], [], [], [], ['^\\', '^\\'], ['^\\', '^\\'], "\001e0\001(a\001e1\001)", '^\(a^\)', s)

		s = Mathemagical::Util::SimpleLaTeX.new(:escape_list=>/_(.)/)
		assert_data("_$a$", [], [], [], [], ['$'], ["_$"], %[\001e0\001a$], '$a$', s)
	end

	it "should accept delimiter option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:delimiter=>"\002\003")
		assert_data("a$b$c", ["<mi>b</mi>"], ["$b$"], [], [], [], [], "a\002\003m0\002\003c",
			"a<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>c", s)

		s = Mathemagical::Util::SimpleLaTeX.new(:delimiter=>%[$])
		assert_data("a$b$c", ["<mi>b</mi>"], ["$b$"], [], [], [], [], "a$m0$c",
			"a<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>c", s)
	end

	it "should accept (d)math_env_list option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:math_env_list=>/%(.*?)%/, :dmath_env_list=>/\[(.*?)\]/)
		assert_data("a$b$c%d%e[f]", ["<mi>d</mi>"], ["%d%"], ["<mi>f</mi>"], ["[f]"], [], [],
			"a$b$c\001m0\001e\001d0\001",
			"a$b$c<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>d</mi></math>e<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>f</mi></math>", s)

		s = Mathemagical::Util::SimpleLaTeX.new(:math_env_list=>[/!(.*?)!/, /"(.*)"/], :dmath_env_list=>[/\#(.*)\#/, /&(.*)&/])
		assert_data('a!b!c"d"e#f#g&h&i',
			["<mi>b</mi>", "<mi>d</mi>"], ['!b!', '"d"'],
			["<mi>f</mi>", "<mi>h</mi>"], ['#f#', '&h&'],
			[], [],
			"a\001m0\001c\001m1\001e\001d0\001g\001d1\001i",
			"a<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>c<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>d</mi></math>e<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>f</mi></math>g<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>h</mi></math>i", s)
	end

	it "should accept throu_list option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:through_list=>[/<%=.*?%>/m, /\(\(.*?\)\)/m])
		assert_data("<%=$a$%>(($b$))", [], [], [], [], [], [], "<%=$a$%>(($b$))", "<%=$a$%>(($b$))", s)

		s = Mathemagical::Util::SimpleLaTeX.new(:through_list=>/<%=.*?%>/)
		assert_data("<%=$a$%>", [], [], [], [], [], [], "<%=$a$%>", "<%=$a$%>", s)
	end

	it "should accept through_list=>[]" do
		s = Mathemagical::Util::SimpleLaTeX.new(:through_list=>[])
		assert_data("$a$", ["<mi>a</mi>"], [%[$a$]], [], [], [], [], "\001m0\001",
			"<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math>", s)
	end

	it "should accept without_parse option" do
		s = Mathemagical::Util::SimpleLaTeX.new(:without_parse=>true)
		encoded, data = s.encode("$a$ $$b$$")
		data.math_list.should == []
		data.msrc_list.should == ["$a$"]
		data.dmath_list.should == []
		data.dsrc_list.should == ["$$b$$"]
		encoded.should == "\001m0\001 \001d0\001"

		s.parse(data)
		data.math_list[0].attributes[:display].should == "inline"
		data.dmath_list[0].attributes[:display].should == "block"
		sma(data.math_list).should == ["<mi>a</mi>"]
		sma(data.dmath_list).should == ["<mi>b</mi>"]
		simplify_math(s.decode(encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math> <math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>")
	end

	it "#set_encode_proc" do
		s = Mathemagical::Util::SimpleLaTeX.new
		s.set_encode_proc(/\{\{/) do |scanner|
			if scanner.scan(/\{\{(.*?)\}\}/m)
				"<%=#{scanner[1]}%>"
			end
		end
		src = "{{$a$}}{{$$b$$}}{{"
		assert_data(src, [], [], [], [], [], [], "\001u0\001\001u1\001{{", "<%=$a$%><%=$$b$$%>{{", s)
		encoded, data = s.encode(src)
		data.user_list.should == ["<%=$a$%>", "<%=$$b$$%>"]
		data.usrc_list.should == ["{{$a$}}", "{{$$b$$}}"]

		s.set_encode_proc(/\{\{/) do |scanner|
		end
		src = "{{a"
		assert_data(src, [], [], [], [], [], [], "{{a", "{{a", s)
		encoded, data = s.encode(src)
		data.user_list.should == []
		data.usrc_list.should == []
	end

	it "#set_encode_proc with arrayed regexp" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = "{{a}}((b)){{(("
		encoded, data = s.encode(src, /\{\{/, /\(\(/) do |scanner|
			case
			when scanner.scan(/\{\{.*?\}\}/)
				"brace"
			when scanner.scan(/\(\(.*?\)\)/)
				"parenthesis"
			end
		end
		encoded.should == "\001u0\001\001u1\001{{(("
		s.decode(encoded, data).should == "braceparenthesis{{(("

		s.set_encode_proc(/\{\{/, /\(\(/) do |scanner|
			case
			when scanner.scan(/\{\{.*?\}\}/)
				"brace"
			when scanner.scan(/\(\(.*?\)\)/)
				"parenthesis"
			end
		end
		encoded, data = s.encode(src)
		encoded.should == "\001u0\001\001u1\001{{(("
		s.decode(encoded, data).should == "braceparenthesis{{(("
	end

	it "#encode accept block" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = "{{$a$}}{{$$b$$}}{{"
		encoded, data = s.encode(src, /\{\{/) do |scanner|
			if scanner.scan(/\{\{(.*?)\}\}/m)
				"<%=#{scanner[1]}%>"
			end
		end
		data.math_list.should == []
		data.dmath_list.should == []
		data.escape_list.should == []
		encoded.should == "\001u0\001\001u1\001{{"
		s.decode(encoded, data).should == "<%=$a$%><%=$$b$$%>{{"
	end

	it "#encode should accept block with #set_encode_proc" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = "{{$a$}}{{$$b$$}}{{"
		s.set_encode_proc(/\{\{/) do |scanner|
			if scanner.scan(/\{\{(.*?)\}\}/m)
				"<%=#{scanner[1]}%>"
			end
		end
		encoded, data = s.encode(src, /\{\{/) do |scanner|
			if scanner.scan(/\{\{(.*?)\}\}/m)
				"<$=#{scanner[1]}$>"
			end
		end
		data.math_list.should == []
		data.dmath_list.should == []
		data.escape_list.should == []
		encoded.should == "\001u0\001\001u1\001{{"
		s.decode(encoded, data).should == "<$=$a$$><$=$$b$$$>{{"
	end

	it "#unencode" do
		src = "$\na\n$\n$$\nb\n$$"
		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode(src)
		s.unencode(encoded, data).should == "$<br />\na<br />\n$\n$$<br />\nb<br />\n$$"

		s = Mathemagical::Util::SimpleLaTeX.new(:delimiter=>%[$])
		e, d = s.encode("$a$")
		s.unencode(e, d).should == "$a$"
	end

	it "#set_rescue_proc" do
		src = '$a\test$ $$b\dummy$$'
		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode(src)
		data.math_list[0].should == "<br />\nUndefined command.<br />\n<code>a<strong>\\test</strong></code><br />"
		data.dmath_list[0].should == "<br />\nUndefined command.<br />\n<code>b<strong>\\dummy</strong></code><br />"

		s.set_rescue_proc do |e|
			e
		end
		encoded, data = s.encode(src)
		data.math_list[0].should be_kind_of(Mathemagical::LaTeX::ParseError)
		data.math_list[0].done.should == "a"
		data.dmath_list[0].should be_kind_of(Mathemagical::LaTeX::ParseError)
		data.dmath_list[0].done.should == "b"
	end

	it "#decode with block" do
		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode('$a$$b$$$c$$$$d$$\e\\\\')
		r = s.decode(encoded, data) do |item, opt|
			case opt[:type]
			when :dmath
				item.attributes[:display].should == "block"
				i = strip_math(item.to_s)
			when :math
				item.attributes[:display].should == "inline"
				i = strip_math(item.to_s)
			else
				i = item
			end
			r = "t#{opt[:type]}i#{opt[:index]}s#{opt[:src]}#{i}"
		end
		r.should == "tmathi0s$a$<mi>a</mi>tmathi1s$b$<mi>b</mi>tdmathi0s$$c$$<mi>c</mi>tdmathi1s$$d$$<mi>d</mi>tescapei0s\\eetescapei1s\\\\\\"

		r = s.decode(encoded, data) do |item, opt|
			nil
		end
		r.should == s.decode(encoded, data)

		s.set_encode_proc(/\{\{/) do |scanner|
			"<%=#{scanner[1]}%>" if scanner.scan(/\{\{(.*?)\}\}/m)
		end
		encoded, data = s.encode("{{a}}{{")
		r = s.decode(encoded, data) do |item, opt|
			item.should == "<%=a%>"
			opt[:type].should == :user
			opt[:index].should == 0
			opt[:src].should == "{{a}}"
			nil
		end
		r.should == "<%=a%>{{"

		s.set_decode_proc do |item, opt|
			"dummy"
		end
		s.decode(encoded, data).should == "dummy{{"
		r = s.decode(encoded, data) do |item, opt|
			nil
		end
		r.should == "<%=a%>{{"
	end

	it "#set_decode_proc" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = '$a$$b$$$c$$$$d$$\e\\\\'
		encoded, data = s.encode(src)
		original_decoded = s.decode(encoded, data)
		s.set_decode_proc do |item, opt|
			case opt[:type]
			when :dmath
				item.attributes[:display].should == "block"
				i = strip_math(item.to_s)
			when :math
				item.attributes[:display].should == "inline"
				i = strip_math(item.to_s)
			else
				i = item
			end
			r = "t#{opt[:type]}i#{opt[:index]}s#{opt[:src]}#{i}"
		end
		encoded, data = s.encode(src)
		r = s.decode(encoded, data)
		r.should == "tmathi0s$a$<mi>a</mi>tmathi1s$b$<mi>b</mi>tdmathi0s$$c$$<mi>c</mi>tdmathi1s$$d$$<mi>d</mi>tescapei0s\\eetescapei1s\\\\\\"

		s.reset_decode_proc
		s.decode(encoded, data).should == original_decoded
	end

	it "#unencode with block" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = '$a$$b$$$c$$$$d$$\e\\\\'
		encoded, data = s.encode(src)
		r = s.unencode(encoded, data) do |item, opt|
			r = "t#{opt[:type]}i#{opt[:index]}#{item.to_s}"
		end
		r.should == "tmathi0$a$tmathi1$b$tdmathi0$$c$$tdmathi1$$d$$tescapei0\\etescapei1\\\\"

		r = s.unencode(encoded, data) do |item, opt|
			nil
		end
		r.should == s.unencode(encoded, data)

		s.set_encode_proc(/\{\{/) do |scanner|
			"<%=#{scanner[1]}%>" if scanner.scan(/\{\{(.*?)\}\}/m)
		end
		encoded, data = s.encode("{{a}}{{")
		r = s.unencode(encoded, data) do |item, opt|
			item.should == "{{a}}"
			opt[:type].should == :user
			opt[:index].should == 0
			nil
		end
		r.should == "{{a}}{{"
	end

	it "#set_unencode_proc" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = '$a$$b$$$c$$$$d$$\e\\\\'
		encoded, data = s.encode(src)
		original_unencoded = s.unencode(encoded, data)

		s.set_unencode_proc do |item, opt|
			r = "t#{opt[:type]}i#{opt[:index]}#{item.to_s}"
		end
		r = s.unencode(encoded, data)
		r.should == "tmathi0$a$tmathi1$b$tdmathi0$$c$$tdmathi1$$d$$tescapei0\\etescapei1\\\\"

		s.set_unencode_proc do |item, opt|
			nil
		end
		s.unencode(encoded, data).should == original_unencoded

		s.set_encode_proc(/\{\{/) do |scanner|
			"<%=#{scanner[1]}%>" if scanner.scan(/\{\{(.*?)\}\}/m)
		end
		encoded, data = s.encode("{{a}}{{")
		s.set_unencode_proc do |item, opt|
			item.should == "{{a}}"
			opt[:type].should == :user
			opt[:index].should == 0
			nil
		end
		r = s.unencode(encoded, data)
		r.should == "{{a}}{{"
	end

	it "#reset_unencode_proc" do
		s = Mathemagical::Util::SimpleLaTeX.new
		s.set_unencode_proc do |item, opt|
			"dummy"
		end
		encoded, data = s.encode("$a$ $$b$$")
		s.unencode(encoded, data).should == "dummy dummy"

		s.reset_unencode_proc
		s.unencode(encoded, data).should == "$a$ $$b$$"
	end

	it "#unencode without escaping" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = %[$<>&'"\n$ $$<>&"'\n$$]
		encoded, data = s.encode(src)
		s.unencode(encoded, data).should == "$&lt;&gt;&amp;&apos;&quot;<br />\n$ $$&lt;&gt;&amp;&quot;&apos;<br />\n$$"
		s.unencode(encoded, data, true).should == src
	end

	it "#decode without parsed" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = '$a$$$b$$\a'
		encoded, data = s.encode(src)
		s.decode(encoded, data, true).should == "$a$$$b$$a"
		s.decode(encoded, data, true) do |item, opt|
			case opt[:type]
			when :math
				item.should == "$a$"
			when :dmath
				item.should == "$$b$$"
			when :escape
				item.should == "a"
			end
		end

		encoded, data = s.encode("$<\n$ $$<\n$$")
		s.decode(encoded, data, true).should == "$&lt;<br />\n$ $$&lt;<br />\n$$"
	end

	it "#decode_partial" do
		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode("$a$$b$")
		simplify_math(s.decode_partial(:math, encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math><math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>")

		s.set_encode_proc(/\\</) do |scanner|
			if scanner.scan(/\\<(.)(.*?)\1>/)
				scanner[2]
			end
		end
		src='$a$$$b$$\c\<.$d$.>'
		encoded, data = s.encode(src)
		simplify_math(s.decode_partial(:math, encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math>\001d0\001\001e0\001\001u0\001")
		simplify_math(s.decode_partial(:dmath, encoded, data)).should == simplify_math("\001m0\001<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>\001e0\001\001u0\001")
		simplify_math(s.decode_partial(:escape, encoded, data)).should == simplify_math("\001m0\001\001d0\001c\001u0\001")
		simplify_math(s.decode_partial(:user, encoded, data)).should == simplify_math("\001m0\001\001d0\001\001e0\001$d$")

		r = s.decode_partial(:math, encoded, data) do |item, opt|
			opt[:type].should == :math
			opt[:src].should == "$a$"
			simplify_math(item.to_s).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math>")
			item
		end
		simplify_math(r).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>a</mi></math>\001d0\001\001e0\001\001u0\001")

		r = s.decode_partial(:dmath, encoded, data) do |item, opt|
			opt[:type].should == :dmath
			opt[:src].should == "$$b$$"
			simplify_math(item.to_s).should == simplify_math("<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>")
			item
		end
		simplify_math(r).should == simplify_math("\001m0\001<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mi>b</mi></math>\001e0\001\001u0\001")

		r = s.decode_partial(:escape, encoded, data) do |item, opt|
			opt[:type].should == :escape
			opt[:src].should == "\\c"
			item.should == "c"
			item
		end
		r.should == "\001m0\001\001d0\001c\001u0\001"

		r = s.decode_partial(:user, encoded, data) do |item, opt|
			opt[:type].should == :user
			opt[:src].should == "\\<.$d$.>"
			item.should == "$d$"
			item
		end
		r.should == "\001m0\001\001d0\001\001e0\001$d$"

		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode("\\a")
		s.decode_partial(:escape, encoded, data).should == "a"
		r = s.decode_partial(:escape, encoded, data) do |item, opt|
		end
		r.should == "\001e0\001"

		s = Mathemagical::Util::SimpleLaTeX.new(:delimiter=>%[$])
		encoded, data = s.encode("$a$")
		s.decode_partial(:math, encoded, data).should =~ /^<math.*<\/math>/m
	end

	it "should keep regexp order" do
		s = Mathemagical::Util::SimpleLaTeX.new
		s.set_encode_proc(/\$/) do |sc|
			if sc.scan(/\$(.*)\z/)
				sc[1]+"is rest"
			end
		end

		encoded, data = s.encode("$a$$b")
		encoded.should == "\001m0\001\001u0\001"
	end

	it "parse eqnarray" do
		s = Mathemagical::Util::SimpleLaTeX.new
		src = <<'EOT'
test
\begin
{eqnarray}
a&=&b\\
c&=&d
\end
{eqnarray}
end
EOT
		encoded, data = s.encode(src, Mathemagical::Util::EQNARRAY_RE) do |scanner|
			if scanner.scan(Mathemagical::Util::EQNARRAY_RE)
				s.parse_eqnarray(scanner[1])
			end
		end
		encoded.should == "test\n\001u0\001\nend\n"
		simplify_math(s.decode(encoded, data)).should == simplify_math("test\n<math display='block' xmlns='http://www.w3.org/1998/Math/MathML'><mtable><mtr><mtd><mi>a</mi></mtd><mtd><mo stretchy='false'>=</mo></mtd><mtd><mi>b</mi></mtd></mtr><mtr><mtd><mi>c</mi></mtd><mtd><mo stretchy='false'>=</mo></mtd><mtd><mi>d</mi></mtd></mtr></mtable></math>\nend\n")

		encoded, data = s.encode('\begin{eqnarray}a\end{eqnarray}', Mathemagical::Util::EQNARRAY_RE) do |scanner|
			s.parse_eqnarray(scanner[1]) if scanner.scan(Mathemagical::Util::EQNARRAY_RE)
		end
		s.decode(encoded, data).should == "<br />\nNeed more column.<br />\n<code>\\begin{eqnarray}a<strong>\\end{eqnarray}</strong></code><br />"
	end

	# TODO COME BACK AND FIX THIS TEST
	# it "should parse single command" do
	# 	s = Mathemagical::Util::SimpleLaTeX.new
	# 	encoded, data = s.encode(%q[\alpha\|\<\>\&\"\'\test], Mathemagical::Util::SINGLE_COMMAND_RE) do |scanner|
	# 		if scanner.scan(Mathemagical::Util::SINGLE_COMMAND_RE)
	# 			s.parse_single_command(scanner.matched)
	# 		end
	# 	end
	# 	encoded.should == "\001u0\001\001e0\001\001e1\001\001e2\001\001e3\001\001e4\001\001e5\001\001u1\001"
	# 	simplify_math(s.decode(encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math>|&lt;&gt;&amp;&quot;&apos;test")
	# 	encoded, data = s.encode('\alpha test', Mathemagical::Util::SINGLE_COMMAND_RE) do |scanner|
	# 		if scanner.scan(Mathemagical::Util::SINGLE_COMMAND_RE)
	# 			s.parse_single_command(scanner.matched)
	# 		end
	# 	end
	# 	encoded.should == "\001u0\001test"
	# 	simplify_math(s.decode(encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math>test")

	# 	encoded, data = s.encode('\alpha  test', Mathemagical::Util::SINGLE_COMMAND_RE) do |scanner|
	# 		if scanner.scan(Mathemagical::Util::SINGLE_COMMAND_RE)
	# 			s.parse_single_command(scanner.matched)
	# 		end
	# 	end
	# 	encoded.should == "\001u0\001 test"
	# 	simplify_math(s.decode(encoded, data)).should == simplify_math("<math display='inline' xmlns='http://www.w3.org/1998/Math/MathML'><mi>&alpha;</mi></math> test")

	# 	encoded, data = s.encode("\\alpha\ntest", Mathemagical::Util::SINGLE_COMMAND_RE) do |scanner|
	# 		if scanner.scan(Mathemagical::Util::SINGLE_COMMAND_RE)
	# 			s.parse_single_command(scanner.matched)
	# 		end
	# 	end
	# 	encoded.should == "\001u0\001\ntest"
	# end

	it "#encode can be called twice or more times" do
		s = Mathemagical::Util::SimpleLaTeX.new
		encoded, data = s.encode('$a$')
		encoded, data = s.encode('$b$', data)
		encoded.should == "\001m1\001"
		data.msrc_list.should == ["$a$", '$b$']
		data.math_list.size.should == 2
		strip_math(data.math_list[0].to_s).should == "<mi>a</mi>"
		strip_math(data.math_list[1].to_s).should == "<mi>b</mi>"

		encoded, data = s.encode('a', data, /a/) do |sc|
			sc.scan(/a/)
		end
		encoded.should == "\001u0\001"
		data.msrc_list.should == ["$a$", '$b$']
		data.usrc_list.should == ["a"]

		encoded, data = s.encode('a', nil, /a/) do |s|
			s.scan(/a/)
		end
		encoded.should == "\001u0\001"
		data.usrc_list.should == ["a"]
	end
end
