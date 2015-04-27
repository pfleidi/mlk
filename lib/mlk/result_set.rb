# encoding: utf-8

require 'forwardable'

module Mlk

  class ResultSet
    extend Forwardable
    include Enumerable

    attr_reader :results

    def_delegators :@results, :each, :include?, :empty?, :size, :length

    def initialize(results)
      validate_results(results)
      @results = results

      # Make sure it's immutable
      @results.freeze
    end

    def all
      ResultSet.new(results)
    end

    def reverse
      ResultSet.new(results.reverse)
    end

    def ==(other)
      other.results == self.results
    end

    def [](name)
      first(:name => name)
    end

    def first(filters = {})
      find(filters).results.first
    end

    def find(filters)
      validate_filters(filters)

      find_results = results.select do |result|
        filters.all? do |param, value|
          if value == :exists
            result.data.has_key?(param.to_s)
          else
            result.data[param.to_s] == value
          end
        end
      end

      ResultSet.new(find_results)
    end

    def find_match(filters)
      validate_filters(filters)

      find_results = results.select do |result|
        filters.all? do |param, value|
          data = result.data[param.to_s]

          if data
            match = case data
                    when Enumerable then data.select { |el| el.match(value) }
                    when String then data.match(value)
                    end

            match && match.size > 0
          end
        end
      end

      ResultSet.new(find_results)
    end

    def group_by(attribute)
      grouped = results.each_with_object({ }) do |result, acc|
        key = result.send(attribute)
        acc[key] ||= []
        acc[key] << result
      end
      grouped.default = [ ]

      grouped
    end

    def sort_by(attribute)
      attribute = attribute.to_sym
      ResultSet.new(results.sort_by(&attribute))
    end

    def paginate(args = {})
      page = args.fetch(:page) { 1 }
      per_page = args.fetch(:per_page) { 5 }
      offset = (page - 1) * per_page

      paginated_results = Array(results.slice(offset, per_page))
      self.class.new(paginated_results)
    end

    private

    def validate_results(res)
      unless res.kind_of?(Enumerable)
        raise ArgumentError, 'You need to pass an instance of Enumerable!'
      end
    end

    def validate_filters(filters)
      unless filters.kind_of?(Hash)
        raise ArgumentError, 'You need to pass a hash with filters.'
      end
    end

  end

end

