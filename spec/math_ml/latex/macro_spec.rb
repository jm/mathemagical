require "math_ml"
require "spec/util"

describe MathML::LaTeX::Macro do
	include MathML::Spec::Util

	before(:all) do
		@src = <<'EOT'
\newcommand{\newcom}{test}
\newcommand{\paramcom}[2]{param2 #2, param1 #1.}
\newcommand\ALPHA\alpha
\newcommand\BETA[1]\beta
\newcommand{\nothing}{}
\newenvironment{newenv}{begin_newenv}{end_newenv}
\newenvironment{paramenv}[2]{begin 1:#1, 2:#2}{end 2:#2 1:#1}
\newenvironment{nothing}{}{}
\newenvironment{separated environment}{sep}{env}
\newenvironment ENV
EOT
	end

	before do
		@m = MathML::LaTeX::Macro.new
		@m.parse(@src)
	end

	it "#parse" do
		@m = MathML::LaTeX::Macro.new
		lambda{@m.parse(@src)}.should_not raise_error

		@m = MathML::LaTeX::Macro.new
		lambda{@m.parse('\newcommand{notcommand}{}')}.should raise_parse_error("Need newcommand.", '\\newcommand{', "notcommand}{}")
		lambda{@m.parse('\newcommand{\separated command}{}')}.should raise_parse_error("Syntax error.", '\newcommand{\separated', " command}{}")
		lambda{@m.parse('\newcommand{\nobody}')}.should raise_parse_error("Need parameter.", '\newcommand{\nobody}', "")
		lambda{@m.parse('\newcommand{\noparam}{#1}')}.should raise_parse_error("Parameter \# too large.", '\newcommand{\noparam}{#', "1}")
		lambda{@m.parse('\newcommand{\overopt}[1]{#1#2}')}.should raise_parse_error("Parameter \# too large.", '\newcommand{\overopt}[1]{#1#', "2}")
		lambda{@m.parse('\newcommand{\strangeopt}[-1]')}.should raise_parse_error("Need positive number.", '\newcommand{\strangeopt}[', "-1]")
		lambda{@m.parse('\newcommand{\strangeopt}[a]')}.should raise_parse_error("Need positive number.", '\newcommand{\strangeopt}[', "a]")

		lambda{@m.parse('\newenvironment{\command}{}{}')}.should raise_parse_error("Syntax error.", '\newenvironment{', '\command}{}{}')
		lambda{@m.parse('\newenvironment{nobegin}')}.should raise_parse_error("Need begin block.", '\newenvironment{nobegin}', "")
		lambda{@m.parse('\newenvironment{noend}{}')}.should raise_parse_error("Need end block.", '\newenvironment{noend}{}', "")
		lambda{@m.parse('\newenvironment{noparam}{#1}{}')}.should raise_parse_error("Parameter \# too large.", '\newenvironment{noparam}{#', "1}{}")
		lambda{@m.parse('\newenvironment{overparam}[1]{#1#2}{}')}.should raise_parse_error("Parameter \# too large.", '\newenvironment{overparam}[1]{#1#', "2}{}")
		lambda{@m.parse('\newenvironment{strangeparam}[-1]{}{}')}.should raise_parse_error("Need positive number.", '\newenvironment{strangeparam}[', "-1]{}{}")
		lambda{@m.parse('\newenvironment{strangeparam}[a]{}{}')}.should raise_parse_error("Need positive number.", '\newenvironment{strangeparam}[', "a]{}{}")

		lambda{@m.parse('\newcommand{\valid}{OK} \invalid{\test}{NG}')}.should raise_parse_error("Syntax error.", '\newcommand{\valid}{OK} ', '\invalid{\test}{NG}')
		lambda{@m.parse('\newcommand{\valid}{OK} invalid{\test}{NG}')}.should raise_parse_error("Syntax error.", '\newcommand{\valid}{OK} ', 'invalid{\test}{NG}')

		lambda{@m.parse('\newcommand{\newcom}[test')}.should raise_parse_error("Option not closed.", '\newcommand{\newcom}', '[test')
		lambda{@m.parse('\newcommand{\newcom}[1][test')}.should raise_parse_error("Option not closed.", '\newcommand{\newcom}[1]', '[test')
		lambda{@m.parse('\newcommand{\newcom}[1][]{#1#2}')}.should raise_parse_error("Parameter \# too large.", '\newcommand{\newcom}[1][]{#1#', '2}')
		lambda{@m.parse('\newenvironment{newenv}[1][test')}.should raise_parse_error("Option not closed.", '\newenvironment{newenv}[1]', '[test')
		lambda{@m.parse('\newenvironment{newenv}[1][test')}.should raise_parse_error("Option not closed.", '\newenvironment{newenv}[1]', '[test')

		lambda{@m.parse('\newcommand{\newcom')}.should raise_parse_error("Block not closed.", '\newcommand', '{\newcom')
		lambda{@m.parse('\newcommand{\newcom}{test1{test2}{test3')}.should raise_parse_error("Block not closed.", '\newcommand{\newcom}', '{test1{test2}{test3')

		lambda{@m.parse('\newenvironment{newenv}[1][]{#1 #2}')}.should raise_parse_error("Parameter \# too large.", '\newenvironment{newenv}[1][]{#1 #', '2}')
	end

	it "#commands" do
		@m.commands("newcom").num.should == 0
		@m.commands("paramcom").num.should == 2
		@m.commands("no").should == nil
	end

	it "#expand_command" do
		@m.expand_command("not coommand", []).should == nil

		@m.expand_command("newcom", []).should == "test"
		@m.expand_command("newcom", ["dummy_param"]).should == "test"
		@m.expand_command("paramcom", ["1", "2"]).should == "param2 2, param1 1."
		@m.expand_command("paramcom", ["12", "34"]).should == "param2 34, param1 12."
		lambda{@m.expand_command("paramcom", ["12"])}.should raise_parse_error("Need more parameter.", "", "")
		lambda{@m.expand_command("paramcom", [])}.should raise_parse_error("Need more parameter.", "", "")
	end

	it "#environments" do
		@m.environments("newenv").num.should == 0
		@m.environments("paramenv").num.should == 2
		@m.environments("not_env").should == nil
		@m.environments("separated environment").num.should == 0
	end

	it "#expand_environment" do
		@m.expand_environment('notregistered', "dummy", []).should == nil
		@m.expand_environment("newenv", "body", []).should == ' begin_newenv body end_newenv '
		@m.expand_environment("paramenv", "body", ["1", "2"]).should == ' begin 1:1, 2:2 body end 2:2 1:1 '
		@m.expand_environment("paramenv", "body", ["12", "34"]).should == ' begin 1:12, 2:34 body end 2:34 1:12 '
		lambda{@m.expand_environment("paramenv", "body", ["1"])}.should raise_parse_error("Need more parameter.", "", "")
		lambda{@m.expand_environment("paramenv", "body", [])}.should raise_parse_error("Need more parameter.", "", "")
		@m.expand_environment("nothing", "body", []).should == '  body  '
		@m.expand_environment("separated environment", "body", []).should == ' sep body env '
		@m.expand_environment("E", "body", []).should == ' N body V '
	end

	it "#expand_with_options" do
		src = <<'EOT'
\newcommand{\opt}[1][x]{#1}
\newcommand{\optparam}[2][]{#1#2}
\newenvironment{newenv}[1][x]{s:#1}{e:#1}
\newenvironment{optenv}[2][]{s:#1}{e:#2}
EOT

		m = MathML::LaTeX::Macro.new
		m.parse(src)

		m.expand_command("opt", []).should == 'x'
		m.expand_command("opt", [], "1").should == '1'

		m.expand_command("optparam", ["1"]).should == '1'
		m.expand_command("optparam", ["1"], "2").should == '21'

		m.expand_environment("newenv", "test", []).should == " s:x test e:x "
		m.expand_environment("newenv", "test", [], "1").should == " s:1 test e:1 "

		m.expand_environment("optenv", "test", ["1"]).should == " s: test e:1 "
		m.expand_environment("optenv", "test", ["1"], "2").should == " s:2 test e:1 "
	end
end
