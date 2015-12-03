require 'spec_helper'

describe Pigeonhole::Collection do
  subject { described_class.new(creation_array) }

  let(:creation_array) { nil }

  let(:location)  { 'loc' }
  let(:unit)      { 'hat' }
  let(:quantity)  { (rand * 100).floor + 1 }

  describe 'initialize with array' do
    let(:creation_array) { [[location, unit, quantity]] }

    it 'should map array to collection' do
      expect(subject.quantity(location: location, unit: unit)).to eq(quantity)
    end

    context 'subarray does not have quantity' do
    let(:creation_array) { [[location, unit]] }

      it 'should assume qty = 1' do
        expect(subject.quantity(location: location, unit: unit)).to eq(1)
      end
    end
  end

  describe 'add' do
    it 'should allow addition' do
      expect(subject.add(location: location, unit: unit, quantity: quantity)).to eq(quantity)
      expect(subject.quantity(location: location, unit: unit)).to eq(quantity)

      expect(subject.add(location: location, unit: unit, quantity: 1)).to eq(quantity + 1)
      expect(subject.quantity(location: location, unit: unit)).to eq(quantity + 1)
    end
  end

  describe 'remove' do
    let(:creation_array) { [[location, unit, quantity]] }

    it 'should allow deletion' do
      expect(subject.remove(location: location, unit: unit, quantity: 1)).to eq(quantity - 1)
    end

    it 'should choke on remove-too-many' do
      expect { subject.remove(location: location, unit: unit, quantity: quantity + 1) }.to raise_error(described_class::CollectionError)
    end
  end

  context 'complex creation' do
    let(:location_b)  { 'locB' }
    let(:unit_b)      { 'unitB' }

    let(:location_a_unit_b) { (rand * 100).floor + 1 }
    let(:location_b_unit_a) { (rand * 100).floor + 1 }
    let(:location_b_unit_b) { (rand * 100).floor + 1 }

    let(:creation_array) { [
      [location, unit, quantity],
      [location, unit_b, location_a_unit_b],
      [location_b, unit, location_b_unit_a],
      [location_b, unit_b, location_b_unit_b]
    ] }

    describe 'quantity' do
      context 'all arguments are nil' do
        it 'should count all entries' do
          expect(subject.quantity).to eq(quantity + location_a_unit_b + location_b_unit_a + location_b_unit_b )
        end
      end

      context 'location is nil' do
        it 'should count item across all locations' do
          expect(subject.quantity(unit: unit)).to eq(quantity + location_b_unit_a)
        end
      end

      context 'unit is nil' do
        it 'should count all in location' do
          expect(subject.quantity(location: location)).to eq(quantity + location_a_unit_b)
        end
      end

      context 'location + unit are both present' do
        it 'should count units at location' do
          expect(subject.quantity(location: location_b, unit: unit_b)).to eq(location_b_unit_b)
        end
      end
    end

    describe '#unit_locations' do
      it 'should count all entries for unit across locations' do
        result = subject.unit_locations(unit: unit)
        expect(result).to match_array(Array.new(quantity, location) + Array.new(location_b_unit_a, location_b))
      end
    end

    describe '#location_units' do
      it 'should count all units at locations' do
        result = subject.location_units(location: location)
        expect(result).to match_array(Array.new(quantity, unit) + Array.new(location_a_unit_b, unit_b))
      end
    end

    describe '#to_a' do
      it 'should return simple array' do
        expect(subject.to_a).to eq(creation_array)
      end
    end
  end
end
