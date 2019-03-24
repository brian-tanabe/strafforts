# == Schema Information
#
# Table name: stripe_customers
#
#  id         :string           not null, primary key
#  athlete_id :integer
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe StripeCustomer, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:athlete_id) }

  it { should belong_to(:athlete) }

  describe '.find_by_email' do
    it 'should get nil when the provided email matches nothing' do
      # act.
      item = StripeCustomer.find_by_email('tony.stark@yahoo.com')

      # assert.
      expect(item).to be_nil
    end

    it 'should get an athlete matching the provided email' do
      # act.
      item = StripeCustomer.find_by_email('tony.stark@avengers.com')

      # assert.
      expect(item.is_a?(StripeCustomer)).to be true
      expect(item.id).to eq('cus_CwoMd03vb539Y4')
    end
  end
end
