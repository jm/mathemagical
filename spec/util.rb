require "rspec"
module MathML
	module Spec
		module Util
			def raise_parse_error(message, done, rest)
				begin
					matcher_class = RSpec::Matchers::DSL::Matcher
				rescue NameError
					matcher_class = RSpec::Matchers::Matcher
				end
				matcher_class.new(:raise_parse_error){
					match do |given|
						begin
							given.call
							@error = nil
						rescue Exception
							@error = $!
						end
						@error.is_a?(MathML::LaTeX::ParseError) &&
							[@error.message, @error.done, @error.rest] == [message, done, rest]
					end
				}.for_expected
			end

			def new_parser
				MathML::LaTeX::Parser.new
			end

			def math_ml(src, display_style=false, parser=nil)
				parser ||= @parser || new_parser
				parser.parse(src, display_style)
			end

			def strip_math_ml(math_ml)
				math_ml.to_s.gsub(/>\s*/, ">").gsub(/\s*</, "<")[/\A<math [^>]*>(.*)<\/math>\Z/m, 1]
			end

			def smml(src, display_style=false, parser=nil)
				strip_math_ml(math_ml(src, display_style, parser))
			end
		end
	end
end
