require 'rails_helper'
require 'webmock/rspec'

describe SuggestionsApi::Client do
  let(:user_id) { 5 }
  let(:host) { URI.parse(described_class::URL_TEMPLATE).host }

  subject do
    VCR.use_cassette('suggestions_api/200', match_requests_on: %i[method host]) do
      described_class.new(user_id).perform
    end
  end

  describe 'success' do
    it 'returns parsed response' do
      expect(subject.size).to eq 9
      subject.each do |record|
        expect(record).to match('car_id' => be_a(Integer), 'rank_score' => be_a(Float))
      end
    end
  end

  describe 'failure' do
    shared_examples 'error' do |error|
      it "raises #{error}" do
        expect { subject }.to raise_error error
      end
    end

    context 'when timeout' do
      before { stub_request(:get, /#{host}/).to_timeout }
      it_behaves_like 'error', HTTP::TimeoutError
    end

    context 'when bad response' do
      before { stub_request(:get, /#{host}/).to_return(status: [500, 'Internal Server Error']) }
      it_behaves_like 'error', Errors::ExternalApi::BadResponse
    end
  end
end
