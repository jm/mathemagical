require "math_ml"

describe MathML::LaTeX::Scanner do
	def new_scanner(src)
		MathML::LaTeX::Scanner.new(src)
	end

	it "#done, #rest" do
		s = new_scanner("0123")
		s.pos = 2
		s.done.should == "01"
		s.rest.should == "23"
	end

	it "#_check" do
		s = new_scanner(" ")
		s._check(/\s/).should == " "
		s.pos.should == 0
	end

	it "#_scan" do
		s = new_scanner(" ")
		s._scan(/\s/).should == " "
		s.pos.should == 1
	end

	it "#check" do
		s = new_scanner(" a")
		s.check(/a/).should == "a"
		s.pos.should == 0
	end

	it "#scan, #reset" do
		s = new_scanner(" a")
		s.scan(/a/).should == "a"
		s.pos.should == 2

		s.reset
		s.pos.should == 0
		s.scan(/b/).should be_nil
		s.pos.should == 0

		s = new_scanner(" %comment\na")
		s.scan(/a/).should == "a"
		s.pos.should == 11

		s.reset
		s.scan(/b/).should be_nil
		s.pos.should == 0
	end

	it "#eos" do
		new_scanner("").should be_eos
		new_scanner(" ").should be_eos
		new_scanner(" %test\n%test").should be_eos
		new_scanner(" a").should_not be_eos
		new_scanner(" \\command").should_not be_eos
	end

	it "#check_command" do
		'\t'.should == '\\t'

		new_scanner("test").check_command.should be_nil
		s = new_scanner(' \test')
		s.check_command.should == '\\test'
		s[1].should == "test"

		new_scanner(' \test next').check_command.should == '\test'
		new_scanner(' \test_a').check_command.should == '\test'
	end

	it "#scan_command" do
		new_scanner("test").scan_command.should be_nil

		s = new_scanner(' \test')
		s.scan_command.should == '\test'
		s[1].should == "test"
		s.pos.should == 6

		s = new_scanner(' \test rest')
		s.scan_command.should == '\test'
		s.pos.should == 6

		s = new_scanner(' \test_a')
		s.scan_command.should == '\test'
		s.pos.should == 6

		s = new_scanner(' \_test')
		s.check_command.should == '\_'
		s.scan_command.should == '\_'
		s.rest.should == "test"
	end

	it "#scan_block" do
		new_scanner(" a").scan_block.should == nil
		new_scanner(" a").check_block.should == nil

		i = " {{}{}{{}{}}} "
		e = "{#{i}}"
		s = new_scanner(" #{e} test")
		s.check_block.should == e
		s.matched.should == e
		s[1].should == i
		s.scan_block.should == e
		s.matched.should == e
		s[1].should == i
		s.rest.should == " test"

		new_scanner(' \command test').scan_block.should == nil
		new_scanner(' \command test').check_block.should == nil

		new_scanner("").scan_block.should == nil
		new_scanner("").check_block.should == nil

		new_scanner(" ").scan_block.should == nil
		new_scanner(" ").check_block.should == nil

		s = new_scanner("{test")
		lambda{s.scan_block}.should raise_error(MathML::LaTeX::BlockNotClosed)
	end

	it "#scan_any" do
		s0 = " %comment\n "
		s1 = "{}"
		s = new_scanner(s0+s1)
		s.scan_any.should == s1
		s.reset
		s.scan_any(true).should == s0+s1
		s.matched.should == s1

		s1 = '\command'
		s = new_scanner(s0+s1)
		s.scan_any.should == s1
		s.reset
		s.scan_any(true).should == s0+s1

		s1 = 'a'
		s = new_scanner(s0+s1)
		s.scan_any.should == s1
		s.reset
		s.scan_any(true).should == s0+s1

		s = new_scanner(" ")
		s.scan_any.should == nil
		s.reset
		s.scan_any(true).should == " "

		s = new_scanner('\begin{env}test\end{env}')
		s.scan_any.should == '\begin'
	end

	it "#peek_command" do
		new_scanner(' \test').peek_command.should == "test"
		new_scanner("").peek_command.should == nil
		new_scanner(" ").peek_command.should == nil
		new_scanner(" a").peek_command.should == nil
	end

	it "#scan_option" do
		s = new_scanner(" []")
		s.scan_option.should == "[]"
		s[1].should == ""
		s.pos.should == 3

		s = new_scanner(" [ opt ]")
		s.scan_option.should == "[ opt ]"
		s[1].should == " opt "
		s.pos.should == 8

		s = new_scanner(" [[]]")
		s.scan_option.should == "[[]"
		s[1].should == "["

		s = new_scanner(" [{[]}]")
		s.scan_option.should == "[{[]}]"
		s[1].should == "{[]}"

		lambda{new_scanner("[").scan_option}.should raise_error(MathML::LaTeX::OptionNotClosed)
	end

	it "#check_option" do
		s = new_scanner(" []")
		s.check_option.should == "[]"
		s[1].should == ""
		s.pos.should == 0

		s = new_scanner(" [ opt ]")
		s.check_option.should == "[ opt ]"
		s[1].should == " opt "
		s.pos.should == 0

		s = new_scanner(" [[]]")
		s.check_option.should == "[[]"
		s[1].should == "["

		s = new_scanner(" [{[]}]")
		s.check_option.should == "[{[]}]"
		s[1].should == "{[]}"

		lambda{new_scanner("[").check_option}.should raise_error(MathML::LaTeX::OptionNotClosed)
	end
end
