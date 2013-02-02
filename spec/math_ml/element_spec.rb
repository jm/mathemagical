require "mathemagical"

describe Mathemagical::Element do
	it "#display_style and #as_display_style" do
		Mathemagical::Element.new("test").display_style.should == nil
		e = Mathemagical::Element.new("test")
		r = e.as_display_style
		r.should equal(e)
		e.display_style.should be_true
	end

	it "#pop" do
		e = Mathemagical::Element.new("super")
		s = Mathemagical::Element.new("sub")

		e.pop.should be_nil

		e << s
		e.pop.should equal(s)
		e.pop.should be_nil

		e << "text"
		e.pop.should == "text"
		e.pop.should be_nil
	end

	it "#to_s" do
		e = Mathemagical::Element.new("e")
		e << "test<"
		e.to_s.should == "<e>test&lt;</e>"
	end
end
