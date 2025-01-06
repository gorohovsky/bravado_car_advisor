require 'rails_helper'

describe AiSuggestionsService do
  describe '#call' do
    let(:user) { create(:user) }

    subject { described_class.new(user).call }

    let(:car_ranking) do
      [
        { 'car_id' => 97, 'rank_score' => 0.9489 },
        { 'car_id' => 179, 'rank_score' => 0.945 }
      ]
    end

    context 'when AI car suggestions for the user are available' do
      before { allow_any_instance_of(SuggestionsApi::Client).to receive(:perform).and_return(car_ranking) }

      it 'returns them' do
        expect(subject).to eq car_ranking
      end
    end

    context 'when the suggestions cannot be retrieved' do
      let(:error) { Errors::Api::BadResponse.new(error_message) }
      let(:error_message) { 'Internal Server Error' }

      before { allow_any_instance_of(SuggestionsApi::Client).to receive(:perform).and_raise(error) }

      it 'enqueues a background job to retrieve them asynchronously and returns empty set' do
        expect(Rails.logger).to receive(:error).with(/#{error_message}/)
        expect(AiSuggestionsJob).to receive(:perform_later).with user.id
        expect(subject).to eq []
      end
    end
  end
end
