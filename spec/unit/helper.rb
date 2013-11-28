# encoding: utf-8

if ENV["CI"]
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require 'mocha/setup'

require 'ostruct'

require 'pry'
require 'pry-debugger'

require 'mlk'
require 'mlk/storage_engines/memory_storage'

begin
  require 'minitest/pride'
rescue LoadError
  # Continue, but without colors
end

Mlk::Model.storage_engine = Mlk::MemoryStorage

def generate_document(header, content = '')
<<-EOF
---
#{ header.inject('') { |acc, val| acc +=  "#{ val[0] }: #{ val[1] }\n" } }
---
#{ content }
EOF
end

def mock_with_attributes(attributes)
  mock_obj = mock
  attributes.each do |attr, value|
    mock_obj.expects(attr).returns(value)
  end

  mock_obj
end
