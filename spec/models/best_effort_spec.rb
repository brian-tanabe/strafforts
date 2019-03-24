# == Schema Information
#
# Table name: best_efforts
#
#  id                  :bigint(8)        not null, primary key
#  activity_id         :bigint(8)
#  athlete_id          :integer
#  best_effort_type_id :integer
#  pr_rank             :integer
#  distance            :float
#  moving_time         :integer
#  elapsed_time        :integer
#  start_date          :datetime
#  start_date_local    :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe BestEffort, type: :model do
  it { should validate_presence_of(:activity_id) }
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:best_effort_type_id) }
  it { should validate_presence_of(:distance) }
  it { should validate_presence_of(:moving_time) }
  it { should validate_presence_of(:elapsed_time) }

  it { should belong_to(:activity) }
  it { should belong_to(:athlete) }
  it { should belong_to(:best_effort_type) }

  describe '.find_top_by_athlete_id_and_best_effort_type_id' do
    it 'should get empty array when the provided athlete_id matches nothing' do
      # act.
      items = BestEffort.find_top_by_athlete_id_and_best_effort_type_id(987654321, 1, 1)

      # assert.
      expect(items).to eq([])
    end

    it 'should get best efforts matching the provided athlete_id' do
      # act.
      items = BestEffort.find_top_by_athlete_id_and_best_effort_type_id(9123806, 12, 3)

      # assert.
      expect(items.count).to be 3
      items.each do |item|
        expect(item.is_a?(BestEffort)).to be true
        expect(item.athlete_id).to eq(9123806)
      end
    end
  end

  describe '.find_top_one_of_each_year' do
    it 'should get empty array when the provided athlete_id matches nothing' do
      # act.
      items = BestEffort.find_top_one_of_each_year(987654321, 1)

      # assert.
      expect(items).to eq([])
    end

    it 'should get best efforts matching the provided athlete_id' do
      # act.
      items = BestEffort.find_top_one_of_each_year(9123806, 12)

      # assert.
      expect(items.count).to be 3
      items.each do |item|
        expect(item.is_a?(BestEffort)).to be true
        expect(item.athlete_id).to eq(9123806)
      end
    end
  end

  describe '.find_all_pbs_by_athlete_id' do
    it 'should get empty array when the provided athlete_id matches nothing' do
      # act.
      items = BestEffort.find_all_pbs_by_athlete_id(987654321)

      # assert.
      expect(items).to eq([])
    end

    it 'should get best efforts matching the provided athlete_id' do
      # act.
      items = BestEffort.find_all_pbs_by_athlete_id(9123806)

      # assert.
      expect(items.count).to be > 0
      items.each do |item|
        expect(item.is_a?(BestEffort)).to be true
        expect(item.athlete_id).to eq(9123806)
      end
    end
  end

  describe '.find_all_pbs_by_athlete_id_and_best_effort_type_id' do
    it 'should get empty array when the provided athlete_id and best_effort_type_id together match nothing' do
      # act.
      items = BestEffort.find_all_pbs_by_athlete_id_and_best_effort_type_id(9123806, 1)

      # assert.
      expect(items).to eq([])
    end

    it 'should get best efforts matching the provided athlete_id and best_effort_type_id' do
      # act.
      items = BestEffort.find_all_pbs_by_athlete_id_and_best_effort_type_id(9123806, 12)

      # assert.
      expect(items.count).to be > 0
      items.each do |item|
        expect(item.is_a?(BestEffort)).to be true
        expect(item.athlete_id).to eq(9123806)
        expect(item.best_effort_type_id).to eq(12)
      end
    end
  end
end
