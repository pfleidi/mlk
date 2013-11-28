# encoding: utf-8

require_relative '../helper'

module Mlk

  describe Model do

    describe "class interface" do

      subject { Model }

      it 'implements the finders interface' do
        subject.must_respond_to :all
        subject.must_respond_to :first
        subject.must_respond_to :find
        subject.must_respond_to :find_match
        subject.must_respond_to :[]
      end

      it 'implements the relationship DSL' do
        subject.must_respond_to :attribute
        subject.must_respond_to :attributes
        subject.must_respond_to :belongs_to
        subject.must_respond_to :has_many
      end

    end

  end

end

