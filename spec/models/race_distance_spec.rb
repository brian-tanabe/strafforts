# == Schema Information
#
# Table name: race_distances
#
#  id         :bigint(8)        not null, primary key
#  distance   :float
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe RaceDistance, type: :model do
  it { should validate_presence_of(:distance) }
  it { should validate_uniqueness_of(:distance) }

  it { should have_many(:races) }

  describe '.find_by_actual_distance' do
    context 'when actual_distance is outside pre-defined margins' do
      it "should get 'Other Distances' when actual_distance is under pre-defined lower margin" do
        # act.
        item = RaceDistance.find_by_actual_distance(4800)

        # assert.
        expect(item.is_a?(RaceDistance)).to be true
        expect(item.distance).to eq(0)
        expect(item.name).to eq('Other Distances')
      end

      it "should get 'Other Distances' when actual_distance is above pre-defined upper margin" do
        # act.
        item = RaceDistance.find_by_actual_distance(5400)

        # assert.
        expect(item.is_a?(RaceDistance)).to be true
        expect(item.distance).to eq(0)
        expect(item.name).to eq('Other Distances')
      end
    end

    context 'when actual_distance is within pre-defined margins' do
      it 'should get the race distance when actual_distance is above pre-defined lower margin' do
        # act.
        item = RaceDistance.find_by_actual_distance(4895)

        # assert.
        expect(item.is_a?(RaceDistance)).to be true
        expect(item.name).to eq('5k')
      end

      it 'should get the race distance when actual_distance is under pre-defined upper margin' do
        # act.
        item = RaceDistance.find_by_actual_distance(5120)

        # assert.
        expect(item.is_a?(RaceDistance)).to be true
        expect(item.name).to eq('5k')
      end
    end
  end

  describe '.find_by_name' do
    it 'should get nil when the provided name matches nothing' do
      # act.
      item = RaceDistance.find_by_name('500 km')

      # assert.
      expect(item).to be_nil
    end

    it 'should get race distance matching the provided name' do
      # act.
      item = RaceDistance.find_by_name('5k')

      # assert.
      expect(item.is_a?(RaceDistance)).to be true
      expect(item.name).to eq('5k')
    end
  end
end
