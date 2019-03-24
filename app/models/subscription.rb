# == Schema Information
#
# Table name: subscriptions
#
#  id                   :bigint(8)        not null, primary key
#  athlete_id           :integer
#  subscription_plan_id :uuid
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  starts_at            :datetime
#  expires_at           :datetime
#  is_deleted           :boolean          default(FALSE)
#  is_active            :boolean          default(TRUE)
#  cancel_at_period_end :boolean          default(FALSE)
#

class Subscription < ApplicationRecord
  validates :athlete_id, :subscription_plan_id, :starts_at, presence: true

  validates :is_deleted, inclusion: { in: [true, false] }
  validates :is_active, inclusion: { in: [true, false] }
  validates :cancel_at_period_end, inclusion: { in: [true, false] }

  belongs_to :athlete, foreign_key: 'athlete_id'
  belongs_to :subscription_plan, foreign_key: 'subscription_plan_id'

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(format(CacheKeys::META, athlete_id: athlete_id))
  end

  def self.find_all_by_athlete_id(athlete_id, is_deleted = false)
    results = where('athlete_id = ?', athlete_id).where('is_deleted = ?', is_deleted)
    results.empty? ? [] : results
  end
end
