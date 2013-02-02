require "mathemagical"

describe Mathemagical do
	it "should not raise error when mathemagical.rb is required twice" do
		if require("lib/mathemagical")
			lambda{Mathemagical::LaTeX::Parser.new}.should_not raise_error
		end
	end

	it "match pcstring behavior" do
		Mathemagical.encode('<>&"\'').to_s.should == "&lt;&gt;&amp;&quot;&apos;"
	end
end
