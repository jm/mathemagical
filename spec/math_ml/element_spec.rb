require "math_ml"

describe MathML::Element do
	it "#display_style and #as_display_style" do
		MathML::Element.new("test").display_style.should == nil
		e = MathML::Element.new("test")
		r = e.as_display_style
		r.should equal(e)
		e.display_style.should be_true
	end

	it "#pop" do
		e = MathML::Element.new("super")
		s = MathML::Element.new("sub")

		e.pop.should be_nil

		e << s
		e.pop.should equal(s)
		e.pop.should be_nil

		e << "text"
		e.pop.should == "text"
		e.pop.should be_nil
	end

	it "#to_s" do
		e = MathML::Element.new("e")
		e << "test<"
		e.to_s.should == "<e>test&lt;</e>"
	end
end
