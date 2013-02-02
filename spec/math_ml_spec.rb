require "math_ml"

describe MathML do
	it "should not raise error when math_ml.rb is required twice" do
		if require("lib/math_ml")
			lambda{MathML::LaTeX::Parser.new}.should_not raise_error
		end
	end

	# it "match pcstring behavior" do
	# 	MathML.encode('<>&"\'').to_s.should == "&lt;&gt;&amp;&quot;&apos;"
	# end
end
