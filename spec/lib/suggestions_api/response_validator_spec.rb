require 'rails_helper'

describe SuggestionsApi::ResponseValidator do
  let(:valid_responses) do
    [
      [{ 'car_id' => 1, 'rank_score' => 0.5 }, { 'car_id' => 2, 'rank_score' => 0.0 }],
      []
    ]
  end

  let(:invalid_responses) do
    [
      { 'car_id' => 1, 'rank_score' => 0.5 },
      'string',
      nil
    ]
  end

  let(:invalid_entries) do
    [
      [{ 'car_id' => 1, 'rank_score' => 0.5, 'extra' => 'extra' }],
      [{ 'car_id' => 1 }],
      [{ 'rank_score' => 0.5 }],
      [{}]
    ]
  end

  let(:invalid_car_ids) do
    [
      [{ 'car_id' => -1, 'rank_score' => 0.5 }],
      [{ 'car_id' => '1', 'rank_score' => 0.5 }],
      [{ 'car_id' => 0, 'rank_score' => 0.5 }],
      [{ 'car_id' => nil, 'rank_score' => 0.5 }]
    ]
  end

  let(:invalid_rank_scores) do
    [
      [{ 'car_id' => 1, 'rank_score' => -0.5 }],
      [{ 'car_id' => 1, 'rank_score' => '0.9' }],
      [{ 'car_id' => 1, 'rank_score' => 1 }],
      [{ 'car_id' => 1, 'rank_score' => nil }]
    ]
  end

  it 'raises no errors for valid responses' do
    valid_responses.each do |response|
      expect { described_class.new(response).validate! }.not_to raise_error
    end
  end

  it 'raises MalformedResponse for responses that are not arrays' do
    invalid_responses.each do |response|
      expect { described_class.new(response).validate! }.to \
        raise_error(Errors::ExternalApi::MalformedResponse, "Invalid response: #{response.inspect}")
    end
  end

  it 'raises MalformedResponse for response entries that are not hashes' do
    invalid_entries.each do |response|
      expect { described_class.new(response).validate! }.to \
        raise_error(Errors::ExternalApi::MalformedResponse, "Invalid entry: #{response.first.inspect}")
    end
  end

  it 'raises MalformedResponse for car_ids that are not positive integers' do
    invalid_car_ids.each do |response|
      expect { described_class.new(response).validate! }.to \
        raise_error(Errors::ExternalApi::MalformedResponse, "Invalid car_id: #{response.first['car_id'].inspect}")
    end
  end

  it 'raises MalformedResponse for rank_scores that are not floats >= 0' do
    invalid_rank_scores.each do |response|
      expect { described_class.new(response).validate! }.to \
        raise_error(Errors::ExternalApi::MalformedResponse, "Invalid rank_score: #{response.first['rank_score'].inspect}")
    end
  end
end
