require 'rails_helper'

describe User, type: :model do
  let!(:user) { create(:user) }
  let(:cache_key) { user.send :cache_key }
  let(:suggestions) { ['an AI suggestion'] }

  before { Rails.cache.clear }

  describe '#ai_car_suggestions' do
    subject { user.ai_car_suggestions }

    context 'when cache is available' do
      before { Rails.cache.write(cache_key, suggestions) }

      it 'returns cached suggestions' do
        expect(SuggestionsApi::Client).not_to receive :new
        expect(subject).to eq suggestions
      end
    end

    context 'when cache is unavailable' do
      context 'when suggestions are successfully retrieved' do
        before { allow_any_instance_of(SuggestionsApi::Client).to receive(:perform).and_return suggestions }

        it 'caches them' do
          expect(Rails.cache.read(cache_key)).to be_nil
          subject
          expect(Rails.cache.read(cache_key)).to eq subject
        end

        it 'returns them' do
          expect(subject).to eq suggestions
        end
      end

      context 'when the API client raises an error' do
        before { allow(SuggestionsApi::Client).to receive_message_chain(:new, :perform).and_raise Errors::Api::BadResponse }

        it 'caches nothing' do
          expect(Rails.cache.read(cache_key)).to be_nil
          expect { subject }.to raise_error(Errors::Api::BadResponse).and \
                                not_change { Rails.cache.read(cache_key) }
        end
      end
    end
  end
end
