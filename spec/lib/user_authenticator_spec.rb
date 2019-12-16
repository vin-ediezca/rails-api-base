require 'rails_helper'

describe UserAuthenticator do
  describe '#perform' do
    context 'when code is incorrect' do
      it 'should raise and error' do
        authenticator = described_class.new('sample_code')
        expect { authenticator.perform }.to raise_error(UserAuthenticator::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
      # it 'should save the user when does not exist' do
      #   authenticator = described_class.new('sample_code')
      #   expect{ authenticator.perform }.to change{ User.count }.by(1)
      # end

      # it "should create user's access token" do
      #   expect{ authenticator.perform }.to change{ AccessToken.count }.by(1)
      #   expect(authenticator.access_token).to be_present
      # end
    end
  end
end