require 'spec_helper'

describe Pigeonhole::Collection do
  subject { described_class.new }

  let(:location)  { 'loc' }
  let(:unit)      { 'hat' }
  let(:quantity)  { (rand * 100).floor + 1 }

  let(:location_b)  { 'locB' }
  let(:unit_b)      { 'unitB' }

  let(:location_a_unit_b) { (rand * 100).floor + 1 }
  let(:location_b_unit_a) { (rand * 100).floor + 1 }
  let(:location_b_unit_b) { (rand * 100).floor + 1 }

  let(:simple_creation_array) { [[location, unit, quantity]] }
  let(:bogus_creation_array) { [[rand.to_s, rand.to_s, 1]] }
  let(:complex_creation_array) { [
    [location, unit, quantity],
    [location, unit_b, location_a_unit_b],
    [location_b, unit, location_b_unit_a],
    [location_b, unit_b, location_b_unit_b]
  ] }

  describe 'initialize' do
    subject { described_class.new(simple_creation_array) }

    it 'should map array to collection' do
      expect(subject.quantity(location: location, unit: unit)).to eq(quantity)
    end

    context 'subarray does not have quantity' do
      subject { described_class.new([[location, unit]]) }

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
    subject { described_class.new(simple_creation_array) }

    it 'should allow deletion' do
      expect(subject.remove(location: location, unit: unit, quantity: 1)).to eq(quantity - 1)
    end

    it 'should choke on remove-too-many' do
      expect { subject.remove(location: location, unit: unit, quantity: quantity + 1) }.to raise_error(described_class::CollectionError)
    end
  end

  describe 'quantity' do
    subject { described_class.new(complex_creation_array) }

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

  describe '#units' do
    subject { described_class.new(complex_creation_array) }

    it 'should count all entries for unit across locations' do
      result = subject.locations(unit: unit)
      expect(result).to match_array(Array.new(quantity, location) + Array.new(location_b_unit_a, location_b))
    end
  end

  describe '#locations' do
    subject { described_class.new(complex_creation_array) }

    it 'should count all units at locations' do
      result = subject.units(location: location)
      expect(result).to match_array(Array.new(quantity, unit) + Array.new(location_a_unit_b, unit_b))
    end
  end

  describe '#to_a' do
    subject { described_class.new(complex_creation_array) }

    it 'should return simple array' do
      expect(subject.to_a).to eq(complex_creation_array)
    end

    it 'should not include empty' do
      # Load the internal hash with a 0
      subject.quantity(unit: rand.to_s)
      expect(subject.to_a).to eq(complex_creation_array)
    end
  end

  describe 'include?' do
    subject { described_class.new(complex_creation_array) }

    context 'with collection argument' do
      it 'should accept Array' do
        expect(subject.include?(simple_creation_array)).to be_truthy
        expect(subject.include?(bogus_creation_array)).to be_falsey
      end

      it 'should accept Collection' do
        collection_b = described_class.new(simple_creation_array)
        expect(subject.include?(collection_b)).to be_truthy

        bogus_collection = described_class.new(bogus_creation_array)
        expect(subject.include?(bogus_collection)).to be_falsey
      end
    end

    context 'with keyword argument' do
      it 'should work with all keywords' do
        expect(subject.include?(location: location)).to be_truthy
        expect(subject.include?(location: rand.to_s)).to be_falsey
      end
    end
  end
end
