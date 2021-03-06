# encoding: utf-8

require 'scrivener'

module Mlk

  class Model
    include Scrivener::Validations
    extend SingleForwardable

    def_delegators :all, :[], :first, :find, :find_match

    class << self
      attr_accessor :storage_engine
    end

    def self.defined_models
      @all_models ||= [ ]
    end

    def self.inherited(subclass)
      defined_models << subclass
    end

    def self.all
      results = storage.all.map do |path, raw_document|
        document = Document.new(raw_document)
        self.new(document, { :path => path })
      end

      ResultSet.new(results)
    end

    def self.add_attribute(attr)
      @attrs ||= [ ]

      @attrs << attr
    end

    # Manage relations between models

    def self.attribute(name, block = -> {})
      define_method(name) do
        data.fetch(name.to_s) do
          block.arity == 1 ? block.call(self) : block.call
        end
      end

      add_attribute(name)
    end

    def self.attributes
      if superclass.respond_to?(:attributes)
        superclass.attributes + @attrs
      else
        @attrs
      end
    end

    def self.has_attribute?(attribute)
      attributes.include?(attribute)
    end

    def self.belongs_to(model, name)
      define_method(name) do
        name = name.to_s
        model_class = Utils.class_lookup(self.class, model)
        model_class.first(:name => self.data[name])
      end
    end

    def self.has_many(model, name, reference = to_reference)
      define_method(name) do
        model_class = Utils.class_lookup(self.class, model)
        if reference.to_s.end_with?("s")
          model_class.find_match(:"#{ reference }" => self.name)
        else
          model_class.find(:"#{ reference }" => self.name)
        end
      end
    end

    def self.storage
      ref = Utils.pluralize(to_reference)
      Model.storage_engine.new(ref)
    end

    def self.to_reference
      self.name.downcase
    end

    attr_reader :document

    attribute :name

    def initialize(document, options = { })
      @path = options[:path]
      @document = document
    end

    def content
      document.content
    end

    def data
      document.data
    end

    def attributes
      self.class.attributes
    end

    def validate
      assert_present(:name)
    end

    def template
      data.fetch('template') { default_template }.to_sym
    end

    def default_template
      self.class.name.split('::').last.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").downcase
    end

    def ==(other_model)
      self.document == other_model.document
    end

    def save
      self.class.storage.save(self.name, @document.serialize)
    end
  end

end

