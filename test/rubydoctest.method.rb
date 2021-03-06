require 'rubygems'
require 'ffi'
require 'os'

class A
 # a suh-weet rdoc
 def go(a=5)
  a = 33
 end

 def self.go22(b=5)
   b = 3
 end
end

=begin
doctest_require: '../lib/ri_for'
>> output = A.ri_for(:go, :want_the_description_returned => true).join(' ')
>> output.include? 'a = 33'
=> true
>> RUBY_VERSION < '1.9' || output.include?('suh-weet')
=> true

>> output = A.new.ri_for(:go, :want_the_description_returned => true).join(' ')
>> output.include? 'a = 33'
=> true
>> RUBY_VERSION < '1.9' || output.include?('suh-weet')
=> true

>> output = A.ri_for(:go22, :want_the_description_returned => true).join(' ')
>> puts output
>> output.include? 'b = 3'
=> true

it should return you something useful

>> A.ri_for(:go22) == nil
=> false
>> A.ri_for(:go) == nil
=> false

it should work with Module
>> FFI::Library.ri_for(:attach_function, :want_the_description_returned => true).nil?
=> false

it should say c method for c
>> output = String.ri_for(:strip, :want_the_description_returned => true).join(' ')
>> output.include?('c method')
=> true
>> output = String.ri_for(:strip)
>> output.nil?
=> false

=end


=begin
doctest:

it should return true if you run it against a "real" class
>> String.desc_class(:want_output => true).length > 1
=> true
>> class A; end
>> A.desc_class(:want_output => true).length > 1
=>  true

it shouldn't report itself as an ancestor of itself
>> A.desc_class(:want_output => true).grep(/ancestors/).include? '[A]'
=> false

also lists constants
>> A.desc_class(:want_output => true, :verbose => true).grep(/constants/i)
=> [] # should be none since we didn't add any constants to A
>> class A; B = 3; end
>> A.desc_class(:want_output => true, :verbose => true).grep(/constants/i).length
=> 1 # should be none since we didn't add any constants to A

should work with sub methods
>> String.ri_for(:strip)

doctest_require: '../lib/ri_for'
=end

=begin 
doctest:
>> require 'pathname'

it should display the name

>> Pathname.instance_method(:children).desc(:want_the_description_returned => true).grep(/children/).size > 0
=>  true # ["#<UnboundMethod: Pathname#children>"]

>> Pathname.instance_method(:children).desc(:want_the_description_returned => true).grep(/Dir.foreach/).size > 0
=> true  # the code itself

and arity
>> Pathname.instance_method(:children).desc(:want_the_description_returned => true).grep(/arity/)
=> ["sig: Pathname#children arity -1"]

it should not duplicate arity
>> A.ri_for(:go, :want_the_description_returned => true).join(' ').scan(/arity/).length
=> 1

wurx with class methods
>> class A; def self.go(a = 3); a=5; end; end
>> class A; def go2(a=4) a =7; end; end
>> A.ri_for(:go)
>> A.ri_for(:go2)

# shouldn't duplicate "appear to be"
doctest: fail
>> a = File.ri_for(:delete, :want_the_description_returned => true).join(' ').scan(/appears to be/).length
=> 1

# should throw our own style exceptions
>> e = nil;begin; File.ri_for(:unknown); rescue NameError => e; end
>> e.to_s.include? "appears that"
=> true

>> a = `#{OS.ruby_bin} test_ri.rb`
>> a.include? "File.delete(file_name"
=> true
=end

=begin
doctest: it should work with method objects themselves
>> b = File.method(:delete)
>> b.ri_for
=> "sig: File.delete arity -1"

# TODO

=end