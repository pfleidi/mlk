# encoding: utf-8

require_relative 'helper'

module Mlk

  describe ResultSet do
    Result = Struct.new(:data)

    let(:all) do
      [
        Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' }),
        Result.new({ 'name' => 'bar', 'show' => 'oww', 'a' => 'c' }),
        Result.new({ 'name' => 'lol', 'show' => 'oww', 'a' => 'c' }),
        Result.new({ 'name' => 'asdf', 'show' => 'hjl', 'a' => 'b' }),

        Result.new({ 'name' => 'huh', 'arr' => %w{ foo bar baz } }),
        Result.new({ 'name' => 'WAT', 'arr' => %w{ jo no baz } }),

        Result.new({ 'name' => 'a', 'other_value' => 'ha' }),
        Result.new({ 'name' => 'b', 'other_value' => 'ho' })
      ]
    end

    subject { ResultSet.new(all)}

    describe '#initialize' do
      it 'sets the correct results' do
        ResultSet.new([ ]).results.must_equal([ ])
      end

      it 'freezes the passed in results object' do
        ResultSet.new([ ]).results.frozen?.must_equal(true)
      end

      it 'checks the passed in results object if it is enumerable' do
        results = mock
        results.expects(:kind_of?).with(Enumerable).returns(true)
        ResultSet.new(results)
      end

      it 'thows an error when invalid results are passed' do
        lambda { ResultSet.new(nil) }.must_raise(ArgumentError)
        lambda { ResultSet.new('') }.must_raise(ArgumentError)
      end
    end

    describe '#all' do
      it 'returns all values' do
        subject.all.must_equal(ResultSet.new(all))
      end
    end

    describe '#reverse' do
      it 'returns all results reversed' do
        subject.reverse.must_equal(ResultSet.new(all.reverse))
      end
    end

    describe '#first' do
      it 'can find a single element by attribute' do
        result = subject.first(name: 'foo')
        result.must_equal(Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' }))
      end

      it 'can find a single element by multiple attributes' do
        result = subject.first(show: 'oww', 'a' => 'x')
        result.must_equal(Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' }))
      end

      it 'can find multiple elements by attribute' do
        result = subject.first(show: 'oww')
        result.must_equal(Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' }))
      end
    end

    describe '#find' do
      it 'returns an empty array when filters do not match' do
        subject.find(non_existing_attribute: 'non_existing_value').must_be_empty
      end

      it 'cannot find elements without any filters' do
        lambda { subject.find }.must_raise(ArgumentError)
      end

      it 'cannot find elements without a filters hash' do
        lambda { subject.find('trololo') }.must_raise(ArgumentError)
      end

      it 'can find a single element by attribute' do
        subject.find(name: 'foo').must_equal(ResultSet.new(
          [Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' })]
        ))
      end

      it 'can find multiple elements by attribute' do
        result = subject.find(show: 'oww')
        result.must_be_kind_of(ResultSet)
        result.size.must_equal(3)
        result.must_include Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' })
        result.must_include Result.new({ 'name' => 'bar', 'show' => 'oww', 'a'=> 'c' })
        result.must_include Result.new({ 'name' => 'lol', 'show' => 'oww', 'a'=> 'c' })
      end

      it 'can find multiple elements by multiple attributes' do
        result = subject.find(show: 'oww', 'a' => 'c')
        result.must_be_kind_of(ResultSet)
        result.size.must_equal(2)
        result.must_include Result.new({ 'name' => 'bar', 'show' => 'oww', 'a'=> 'c' })
        result.must_include Result.new({ 'name' => 'lol', 'show' => 'oww', 'a'=> 'c' })
      end

      it 'can find elements by attribute existance' do
        result = subject.find(other_value: :exists)
        result.size.must_equal(2)
      end

      it 'can find results by attribute' do
        found = subject.find(show: 'oww')
        found.must_be_kind_of(ResultSet)

        found.must_equal(ResultSet.new([
          Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' }),
          Result.new({ 'name' => 'bar', 'show' => 'oww', 'a' => 'c' }),
          Result.new({ 'name' => 'lol', 'show' => 'oww', 'a' => 'c' })
        ]))
      end

      it 'supports chained find()' do
        found = ResultSet.new(all).find(show: 'oww')
        found.find(name: 'bar').must_equal(ResultSet.new([
          Result.new({ 'name' => 'bar', 'show' => 'oww', 'a' => 'c' })
        ]))
      end
    end

    describe '#find_match' do
      it 'retuns an empty array when filters do not match' do
        subject.find_match(non_existing_attribute: 'non_existing_value').must_be_empty
      end

      it 'cannot find elements without any filters' do
        lambda { subject.find_match }.must_raise(ArgumentError)
      end

      it 'cannot find elements without a filters hash' do
        lambda { subject.find_match('fufu') }.must_raise(ArgumentError)
      end

      it 'can find elements by single match attribute' do
        result = subject.find_match(arr: "baz")
        result.must_be_kind_of(ResultSet)
        result.size.must_equal(2)
        result.must_include Result.new({ 'name' => 'huh', 'arr' => %w{ foo bar baz } })
        result.must_include Result.new({ 'name' => 'WAT', 'arr' => %w{ jo no baz } })
      end

      it 'can find elements by multiple match attributes' do
        result = subject.find_match(arr: 'baz', name: 'WAT')
        result.must_be_kind_of(ResultSet)
        result.size.must_equal(1)
        result.must_include Result.new({ 'name' => 'WAT', 'arr' => %w{ jo no baz } })
      end

      it 'can find elements by regex' do
        result = subject.find_match(name: /(foo|bar)/)
        result.size.must_equal(2)
        result.must_include Result.new({ 'name' => 'foo', 'show' => 'oww', 'a' => 'x' })
        result.must_include Result.new({ 'name' => 'bar', 'show' => 'oww', 'a'=> 'c' })
      end
    end

    describe '#group_by' do
      let(:grouped) do
        ResultSet.new([
          mock_with_attributes(show: 'foo'),
          mock_with_attributes(show: 'bar'),
          mock_with_attributes(show: 'baz')
        ]).group_by(:show)
      end

      it 'can group results by attribute' do
        grouped.size.must_equal(3)
      end

      it 'contains the right keys' do
        grouped.keys.must_include('foo')
        grouped.keys.must_include('bar')
        grouped.keys.must_include('baz')
      end

      it 'returns empty arrays for keys not available' do
        grouped[:does_not_exist].must_equal([ ])
      end
    end

    describe '#sort_by' do
      it 'can sort results by attribute' do
        results = mock
        results.expects(:kind_of?).with(Enumerable).returns(true)
        results.expects(:sort_by).returns([ ])

        ResultSet.new(results).sort_by(:name).results.must_equal([ ])
      end
    end

    describe '#paginate' do
      describe 'with the default page size' do
        it 'returns the first 5 elements of the results collection' do
          paginated = subject.paginate
          paginated.size.must_equal(5)
          paginated.results.must_equal(all.first(5))
        end

        it 'returns the rest of the elements for the second page' do
          paginated = subject.paginate(:page => 2)
          paginated.size.must_equal(3)
          paginated.results.must_equal(all.last(3))
        end

        it 'returns an empty result set for out of range pages' do
          paginated = subject.paginate(:page => 5)
          paginated.size.must_equal(0)
        end

        it 'returns an empty result set for negative pages' do
          paginated = subject.paginate(:page => -1)
          paginated.size.must_equal(0)
        end
      end

      describe 'with a custom page size' do
        let(:per_page) { 3 }

        it 'returns the first 3 elements of the results collection' do
          paginated = subject.paginate(:per_page => per_page)
          paginated.size.must_equal(3)
          paginated.results.must_equal(all.first(3))
        end

        it 'returns elements 4 - 6 of the results collection' do
          paginated = subject.paginate(:page => 2, :per_page => per_page)
          paginated.size.must_equal(3)
          paginated.results.must_equal(all.slice(3..5))
        end

        it 'returns the last 2 elements of the results collection' do
          paginated = subject.paginate(:page => 3, :per_page => per_page)
          paginated.size.must_equal(2)
          paginated.results.must_equal(all.last(2))
        end
      end
    end
  end

end

