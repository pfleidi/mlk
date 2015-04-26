# encoding: utf-8

require_relative '../helper'

module Mlk

  describe Model do
    class TestModel < Model
      attribute :test
    end

    class OtherModel < TestModel
      attribute :asdf
      attribute :other, -> { 'fallback' }
      attribute :asdf2, ->(i) { i.asdf }
    end

    let(:data) { { 'name' => 'foobert', 'foo' => 'bar' } }
    let(:document) { stub(:content => 'content', :data => data) }

    subject { Model.new(document) }

    describe '.attribute' do
      let(:data) { { 'asdf' => 'woohoo', 'name' => 'a', 'test' => 'b' } }

      let(:model_instance) { TestModel.new(document) }
      let(:model2_instance) { OtherModel.new(document) }

      it 'should have valid getter methods' do
        model_instance.must_respond_to(:name)
        model_instance.must_respond_to(:test)
      end

      it 'returns the valid values' do
        model_instance.name.must_equal('a')
        model_instance.test.must_equal('b')
      end

      it 'returns default values' do
        model2_instance.other.must_equal('fallback')
      end

      it 'returns default values that use a method' do
        model2_instance.asdf2.must_equal('woohoo')
      end
    end

    describe '.attributes' do
      it 'should return the correct attributes' do
        TestModel.attributes.must_equal([ :name, :test ])
      end

      it 'should return the correct inherited attributes' do
        OtherModel.attributes.must_equal([ :name, :test, :asdf, :other, :asdf2])
      end
    end

    describe '.has_attribute?' do
      it 'returns true if the model has the attribute' do
        TestModel.has_attribute?(:name).must_equal(true)
      end

      it 'returns false if model does not have the attribute' do
        TestModel.has_attribute?(:woof).must_equal(false)
      end
    end

    describe '#content' do
      it 'returns the correct content' do
        subject.content.must_equal('content')
      end
    end

    describe '#data' do
      it 'returns the correct data' do
        subject.data.must_equal(data)
      end
    end

    describe '#name' do
      it 'returns the correct name' do
        subject.name.must_equal('foobert')
      end
    end

    describe '#attributes' do
      it 'delegates to the class method' do
        Model.expects(:attributes).returns([:foo, :bar])
        subject.attributes.must_equal([:foo, :bar])
      end
    end

    describe '#valid?' do
      it 'is invalid without a name' do
        document.stubs(:data).returns({ 'name' => nil })
        Model.new(document).valid?.must_equal(false)
      end

      it 'is valid with a name' do
        document = stub(content: 'CONTENT', data: { 'name' => 'Peter' })
        Model.new(document).valid?.must_equal(true)
      end
    end

    describe '#template' do
      describe 'without a given template' do
        it 'returns the default template' do
          subject.template.must_equal(:model)
        end
      end

      describe 'with a given template and a CamelCase name' do
        it 'returns the default template' do
          OtherModel.new(document).template.must_equal(:other_model)
        end
      end

      describe 'with a given template' do
        before { data['template'] = 'my_template' }

        it 'returns the given template' do
          subject.template.must_equal(:my_template)
        end
      end
    end
  end

end

