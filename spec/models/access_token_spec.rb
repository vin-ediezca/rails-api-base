require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should have valid factory' do
      user = FactoryBot.create :user
      expect(FactoryBot.build :access_token, user_id: user.id).to be_valid
    end

    it 'should validate presence of token' do
      access_token = FactoryBot.build :access_token, token: ''
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:token]).to include("can't be blank")
    end
  end

  describe '#new' do
    it 'should have a token present after initialize' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should generate uniq token' do
      user = FactoryBot.create :user
      expect { user.create_access_token }.to change { AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'should generate token once' do
      user = FactoryBot.create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
