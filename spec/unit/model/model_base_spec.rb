# encoding: utf-8

require_relative '../helper'

module Mlk

  class TestModel < Model
    attribute :test
  end

  class OtherModel < TestModel
    attribute :asdf
  end

  describe Model do
    let(:data) { { 'name' => 'foobert', 'foo' => 'bar' } }
    let(:document) { stub(:content => 'content', :data => data) }

    subject { Model.new(document) }

    describe '.attribute' do
      let(:data) { { 'name' => 'a', 'test' => 'b' } }

      let(:model_instance) do
        TestModel.new(document)
      end

      it 'should have valid getter methods' do
        model_instance.must_respond_to(:name)
        model_instance.must_respond_to(:test)
      end

      it 'returns the valid values' do
        model_instance.name.must_equal('a')
        model_instance.test.must_equal('b')
      end
    end

    describe '.attributes' do
      it 'should return the correct attributes' do
        TestModel.attributes.must_equal([ :name, :test ])
      end

      it 'should return the correct inherited attributes' do
        OtherModel.attributes.must_equal([ :name, :test, :asdf ])
      end
    end

    describe '.has_attribute?' do
      # TODO write tests and implement
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
  end

end

