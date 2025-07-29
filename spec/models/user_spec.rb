require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user1) { User.create(name: 'Bheki') }
  let(:user2) { User.create(name: 'John') }

  describe 'validations' do
    it 'name should be present' do
      user1.name = nil
      expect(user1).to_not be_valid
    end
  end

  describe 'associations' do
    it 'has many clients' do
      association = User.reflect_on_association(:clients)
      expect(association.macro).to eq :has_many
    end

    it 'has one setting' do
      association = User.reflect_on_association(:setting)
      expect(association.macro).to eq :has_one
    end

    it 'has one subscription' do
      association = User.reflect_on_association(:subscription)
      expect(association.macro).to eq :has_one
    end
  end
end