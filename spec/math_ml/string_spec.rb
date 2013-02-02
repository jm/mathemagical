require "mathemagical/string"

describe Mathemagical::String do
	it ".mathml_latex_parser" do
		Mathemagical::String.mathml_latex_parser.should be_kind_of(Mathemagical::LaTeX::Parser)
		mlp = Mathemagical::LaTeX::Parser.new
		Mathemagical::String.mathml_latex_parser = mlp
		Mathemagical::String.mathml_latex_parser.should equal(mlp)
		lambda{Mathemagical::String.mathml_latex_parser=String}.should raise_error(TypeError)
		Mathemagical::String.mathml_latex_parser.should equal(mlp)

		Mathemagical::String.mathml_latex_parser = nil
		Mathemagical::String.mathml_latex_parser.should be_kind_of(Mathemagical::LaTeX::Parser)
		Mathemagical::String.mathml_latex_parser.should_not equal(mlp)
	end
end

describe String do
	it "#parse" do
		mlp = Mathemagical::LaTeX::Parser.new
		"".to_mathml.to_s.should == mlp.parse("").to_s
		"".to_mathml(true).to_s.should == mlp.parse("", true).to_s

		Mathemagical::String.mathml_latex_parser.macro.parse(<<'EOT')
\newcommand{\test}{x}
EOT
		'\test'.to_mathml.to_s.should == mlp.parse("x").to_s
	end
end
