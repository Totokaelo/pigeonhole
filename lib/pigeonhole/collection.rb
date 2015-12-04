module Pigeonhole
  class Collection
    # Array should contain Arrays of [location, unit(, qty)], ie look like:
    #   [
    #     [location, unit(, qty)](,...)
    #   ]
    def initialize(array = nil)
      if array
        array.each do |location, unit, quantity|
          quantity ||= 1

          if quantity > 0
            add(location: location, unit: unit, quantity: quantity)
          end
        end
      end
    end

    # MODIFY METHODS

    def add(location:, unit:, quantity: 1)
      raise_if_shitty(location, unit, quantity)

      locations_to_units[location][unit] += quantity
    end

    def remove(location:, unit:, quantity: 1)
      raise_if_shitty(location, unit, quantity)

      current_quantity_at_location = locations_to_units[location][unit]

      if current_quantity_at_location < quantity
        entry_code = "#{unit}@#{location}"
        raise CollectionError.new("#{entry_code}: Cannot remove #{quantity}: only #{current_quantity_at_location} at location")
      end

      locations_to_units[location][unit] -= quantity
    end

    # QUERY METHODS

    def quantity(location: nil, unit: nil)
      sum(quantities(location, unit))
    end

    def locations(unit: nil)
      if unit
        locations_to_units.flat_map do |location, unit_hash|
          Array.new(unit_hash[unit], location)
        end
      else
        locations_to_units.keys
      end
    end

    def units(location: nil)
      if location
        locations_to_units[location].flat_map do |unit, qty|
          Array.new(qty, unit)
        end
      else
        locations_to_units.values.flat_map(&:keys)
      end
    end

    def include?(arg = nil, location: nil, unit: nil, quantity: 1)
      if arg
        if arg.is_a?(Array) || arg.is_a?(Collection)
          include_collection?(arg)
        else
          raise ArgumentError.new("Argument must be a collection (#{arg})")
        end

      else
        if location.nil? && unit.nil?
          raise ArgumentError.new('Either location or unit must be present')
        end

        quantity(location: location, unit: unit) >= quantity
      end
    end

    # EXPORT

    def to_a
      locations_to_units.flat_map do |location, unit_hash|
        unit_hash.map do |unit, quantity|
          if quantity > 0
            [location, unit, quantity]
          end
        end
      end.compact
    end

    CollectionError = Class.new(StandardError)

    private

    def quantities(location, unit)
      if    location      && unit
        [locations_to_units[location][unit]]

      elsif location.nil? && unit
        locations_to_units.values.map { |unit_hash| unit_hash[unit] }

      elsif location      && unit.nil?
        locations_to_units[location].values

      elsif location.nil? && unit.nil?
        locations_to_units.values.flat_map(&:values)

      end
    end

    # This ends up looking like:
    # {
    #   location_a => { unit_a => 5, unit_b => 0 },
    #   location_b => { unit_a => 0, unit_b => 1 }
    # }
    #
    def locations_to_units
      if @locations_to_units.nil?
        @locations_to_units = Hash.new do |location_hash, location|
          location_hash[location] = Hash.new do |unit_hash, unit|
            unit_hash[unit] = 0
          end
        end
      end

      @locations_to_units
    end

    def raise_if_shitty(location, unit, quantity)
      raise ArgumentError.new('location cannot be nil') if location.nil?
      raise ArgumentError.new('unit cannot be nil')     if unit.nil?
      raise ArgumentError.new('Cannot add less than 1') if quantity < 1
    end

    def include_collection?(collection)
      collection.to_a.all? do |entry|
        location, unit, quantity = entry

        include?(location: location, unit: unit, quantity: quantity)
      end
    end

    def sum(quantities)
      quantities.reduce(0, :+)
    end
  end
end
