require "math_ml/string"

describe MathML::String do
	it ".mathml_latex_parser" do
		MathML::String.mathml_latex_parser.should be_kind_of(MathML::LaTeX::Parser)
		mlp = MathML::LaTeX::Parser.new
		MathML::String.mathml_latex_parser = mlp
		MathML::String.mathml_latex_parser.should equal(mlp)
		lambda{MathML::String.mathml_latex_parser=String}.should raise_error(TypeError)
		MathML::String.mathml_latex_parser.should equal(mlp)

		MathML::String.mathml_latex_parser = nil
		MathML::String.mathml_latex_parser.should be_kind_of(MathML::LaTeX::Parser)
		MathML::String.mathml_latex_parser.should_not equal(mlp)
	end
end

describe String do
	it "#parse" do
		mlp = MathML::LaTeX::Parser.new
		"".to_mathml.to_s.should == mlp.parse("").to_s
		"".to_mathml(true).to_s.should == mlp.parse("", true).to_s

		MathML::String.mathml_latex_parser.macro.parse(<<'EOT')
\newcommand{\test}{x}
EOT
		'\test'.to_mathml.to_s.should == mlp.parse("x").to_s
	end
end
