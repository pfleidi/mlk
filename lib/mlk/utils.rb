# encoding: utf-8

module Mlk

  module Utils

    def self.class_lookup(context, klass)
      case klass
      when Symbol
        klass.to_s.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      else klass
      end
    end

    def self.pluralize(str)
      if str.end_with?('y')
        str.gsub(/y$/, 'ies')
      else
        str + 's'
      end
    end

  end

end

