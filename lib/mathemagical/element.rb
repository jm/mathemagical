module Mathemagical
	class Element
		attr_reader :display_style, :attributes, :children
		attr_accessor :name

		def initialize(name, options = {})
			@name = name
			@attributes = options
			@children = []
		end

		def as_display_style
			@display_style = true
			self
		end

		def []=(key, value)
			@attributes[key.to_sym] = value
		end

		def [](key)
			@attributes[key.to_sym]
		end

		def <<(*obj)
			@children += obj.flatten.map {|o| o.is_a?(String) ? Mathemagical.encode(o) : o }

			self
		end

		def to_s
			children.empty? ? self_closing_xml : xml
		end

		def self_closing_xml
			"<#{@name}#{build_attributes_string} />"
		end

		def xml
			"<#{@name}#{build_attributes_string}>
				#{child_ml}
			</#{@name}>".gsub(/[\n\t]/, '')
		end

		def child_ml
			@children.map(&:to_s).join("\n")
		end

		def build_attributes_string
			return if @attributes.empty?

			" " + @attributes.map do |key, value|
				"#{key}='#{value}'"
			end.join(" ")
		end

		def pop
			@children.pop
		end
	end

	module Variant
		NORMAL = "normal"
		BOLD = "bold"
		BOLD_ITALIC = "bold-italic"
		def variant=(v)
			self["mathvariant"] = v
		end
	end

	module Align
		CENTER = "center"
		LEFT = "left"
		RIGHT = "right"
	end

	module Line
		SOLID = "solid"
		NONE = "none"
	end

	class Math < Element
		def initialize(display_style)
			super("math", "xmlns"=>"http://www.w3.org/1998/Math/MathML")
			self[:display] = display_style ? "block" : "inline"
		end
	end

	class Row < Element
		def initialize
			super("mrow")
		end
	end

	class Break < Element
		def initialize
			super("br", :xmlns => 'http://www.w3.org/1999/xhtml')
		end
	end

	class None < Element
		def initialize
			super("none")
		end
	end

	class Space < Element
		def initialize(width)
			super("mspace", "width"=>width)
		end
	end

	class Fenced < Element
		attr_reader :open, :close

		def initialize
			super("mfenced")
		end

		def open=(o)
			o = "" if o.to_s=="." || !o
			o = "{" if o.to_s=="\\{"
			self[:open] = Mathemagical.encode(o)
		end

		def close=(c)
			c = "" if c.to_s=="." || !c
			c = "}" if c.to_s=="\\}"
			self[:close] = Mathemagical.encode(c)
		end
	end

	class Frac < Element
		def initialize(numerator, denominator)
			super("mfrac")
			self << numerator
			self << denominator
		end
	end

	class SubSup < Element
		attr_reader :sub, :sup, :body

		def initialize(display_style, body)
			super("mrow")
			as_display_style if display_style
			@body = body
		end

		def update_name
			if @sub || @sup
				name = "m"
				name << (@sub ? (@display_style ? "under" : "sub") : "")
				name << (@sup ? (@display_style ? "over" : "sup") : "")
			else
				name = "mrow"
			end
			self.name = name
		end
		private :update_name

		def update_contents
			children.clear
			children << @body
			children << @sub if @sub
			children << @sup if @sup
		end
		private :update_contents

		def update
			update_name
			update_contents
		end
		private :update

		def sub=(sub)
			@sub = sub
			update
		end

		def sup=(sup)
			@sup = sup
			update
		end
	end

	class Over < Element
		def initialize(base, over)
			super("mover")
			self << base << over
		end
	end

	class Under < Element
		def initialize(base, under)
			super("munder")
			self << base << under
		end
	end

	class Number < Element
		def initialize
			super("mn")
		end

		def <<(o)
			@children << o
			self
		end
	end

	class Identifier < Element
		def initialize
			super("mi")
		end

		def <<(o)
			@children << Mathemagical.encode(o)
			self
		end
	end

	class Operator < Element
		def initialize
			super("mo")
		end

		def <<(o)
			@children << Mathemagical.encode(o)
			self
		end
	end

	class Text < Element
		def initialize
			super("mtext")
		end

		def <<(o)
			@children << Mathemagical.encode(o)
			self
		end
	end

	class Sqrt < Element
		def initialize
			super("msqrt")
		end
	end

	class Root < Element
		def initialize(index, base)
			super("mroot")
			self << base
			self << index
		end
	end

	class Table < Element
		def initialize
			super("mtable")
		end

		def set_align_attribute(name, a, default)
			if a.is_a?(Array) && a.size>0
				value = ""
				a.each do |i|
					value << " "+i
				end
				if value =~ /^( #{default})*$/
					@attributes.delete(name)
				else
					@attributes[name] = value.strip
				end
			else
				@attributes.delete(name)
			end
		end

		def aligns=(a)
			set_align_attribute("columnalign", a, Align::CENTER)
		end

		def vlines=(a)
			set_align_attribute("columnlines", a, Line::NONE)
		end

		def hlines=(a)
			set_align_attribute("rowlines", a, Line::NONE)
		end
	end

	class Tr < Element
		def initialize
			super("mtr")
		end
	end

	class Td < Element
		def initialize
			super("mtd")
		end
	end
end
