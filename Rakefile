load "Rakefile.utirake"

VER = "0.14"

UtiRake.setup do
	external("https://hg.hinet.mydns.jp", %w[eim_xml])

	rdoc do |t|
		t.title = "MathML Library"
		t.main = "README"
		t.rdoc_files.include(FileList["lib/**/*.rb", "README"])
	end

	publish("mathml", "hiraku") do
		cp "index.html", "html/index.html"
	end

	gemspec do |s|
		s.name = "math_ml"
		s.rubyforge_project = "mathml"
		s.version = VER
		s.summary = "MathML Library"
		s.author = "KURODA Hiraku"
		s.email = "hiraku@hinet.mydns.jp"
		s.homepage = "http://mathml.rubyforge.org/"
		s.add_dependency("eim_xml")
	end

	rcov_spec do |s|
		s.ruby_opts = %w[-rubygems]
		s.pattern ||= %w[spec/util.rb spec/**/*_spec.rb]
		s.pattern = [s.pattern] unless s.pattern.is_a?(Array)
#		s.pattern << "symbols/**/*_spec.rb"
	end

	spec do |s|
#		s.spec_opts << "-b"
	end
	alias_task
end

namespace :spec do
	RSpec::Core::RakeTask.new(:symbols) do |s|
		s.pattern = "./symbols/**/*_spec.rb"
		s.rspec_opts = %w[-c -I lib -I external/lib]
	end
end

task :package do
	name = "math_ml-#{VER}"
	cp "external/eim_xml/lib/eim_xml.rb", "pkg/#{name}/lib/"
	Dir.chdir "pkg" do
		rm "#{name}.tar.gz"
		sh "tar zcf #{name}.tar.gz #{name}/"
	end
end

task :default => :spec
task "spec:no_here" => "spec:apart"
task :all => [:spec, "spec:symbols"]
