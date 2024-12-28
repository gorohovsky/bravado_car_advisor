require 'rails_helper'
require 'support/helper_methods'

describe 'CarRecommendations', type: :request do
  describe 'GET /index' do
    let(:user) { create(:user) }
    let(:params) { { user_id: user.id } }

    before { allow_any_instance_of(SuggestionsApi::Client).to receive(:perform).and_raise HTTP::TimeoutError }

    after { Faker::UniqueGenerator.clear }

    subject do
      get car_recommendations_url, params: params
      response
    end

    describe 'pagination' do
      let!(:cars) { create_list(:car, 21) }

      shared_examples 'correct response' do |entries_number|
        it 'contains correct number of entries per page' do
          expect(JSON.parse(subject.body).size).to eq entries_number
        end
      end

      context 'when page is not provided' do
        it_behaves_like 'correct response', 20
      end

      context 'when page is provided' do
        let(:params) { super().merge!(page: 2) }
        it_behaves_like 'correct response', 1
      end
    end

    describe 'ordering' do
      let(:brand) { create(:brand) }
      let(:user)  { create(:user, preferred_brands: [brand]) }

      let!(:car_brand_match_with_rank)        { create(:car, price: 7000, brand:) }
      let!(:car_no_match_no_rank)             { create(:car, price: 25_000) }
      let!(:car_brand_price_match_with_rank)  { create(:car, price: 11_000, brand:) }
      let!(:car_brand_match_no_rank)          { create(:car, price: 5000, brand:) }
      let!(:car_no_match_with_rank)           { create(:car, price: 100_000) }
      let!(:car_brand_match_with_rank2)       { create(:car, price: 9000, brand:) }
      let!(:car_brand_price_match_with_rank2) { create(:car, price: 15_000, brand:) }
      let!(:car_no_match_no_rank2)            { create(:car, price: 15_000) }
      let!(:car_brand_price_match_no_rank)    { create(:car, price: 10_000, brand:) }

      let(:car_ranking) do
        [
          { 'car_id' => car_brand_price_match_with_rank2.id, 'rank_score' => 0.5 },
          { 'car_id' => car_brand_price_match_with_rank.id, 'rank_score' => 0.3 },
          { 'car_id' => car_brand_match_with_rank2.id, 'rank_score' => 0.7 },
          { 'car_id' => car_brand_match_with_rank.id, 'rank_score' => 0.65 },
          { 'car_id' => car_no_match_with_rank.id, 'rank_score' => 0.8 }
        ]
      end

      let(:ordered_cars) do
        [
          car_brand_price_match_with_rank2,
          car_brand_price_match_with_rank,
          car_brand_price_match_no_rank,
          car_brand_match_with_rank2,
          car_brand_match_with_rank,
          car_brand_match_no_rank,
          car_no_match_with_rank,
          car_no_match_no_rank2,
          car_no_match_no_rank
        ]
      end
      let(:ordered_labels) { ['perfect_match', 'good_match', nil].flat_map { [_1] * 3 } }
      let(:ordered_ranks)  { [0.5, 0.3, nil, 0.7, 0.65, nil, 0.8, nil, nil] }

      before { allow_any_instance_of(SuggestionsApi::Client).to receive(:perform).and_return car_ranking }

      it 'responds with 200 and correctly ordered cars' do
        expect(subject.status).to eq 200

        expect(JSON.parse(subject.body)).to eq(
          ordered_cars.zip(ordered_ranks, ordered_labels).map do |car, rank, label|
            car_to_hash(car, rank:, label:)
          end
        )
      end
    end

    describe 'request parameters' do
      let!(:bmw_car)  { create(:car, :with_brand, brand_name: 'BMW', price: 4000) }
      let!(:audi_car) { create(:car, :with_brand, brand_name: 'Audi', price: 5000) }

      shared_examples 'correct response' do
        it 'responds with 200 and cars matching the criteria' do
          expect(subject.status).to eq 200

          JSON.parse(subject.body).tap do |payload|
            expect(payload.size).to eq 1
            expect(payload.first).to eq car_to_hash(expected_car)
          end
        end
      end

      describe 'query' do
        context 'when supplied full brand name' do
          let(:params) { super().merge!(query: 'BMW') }
          let(:expected_car) { bmw_car }

          it_behaves_like 'correct response'
        end

        context 'when supplied partial brand name' do
          let(:params) { super().merge!(query: 'Au') }
          let(:expected_car) { audi_car }

          it_behaves_like 'correct response'
        end

        context 'when a brand does not exist' do
          let(:params) { super().merge!(query: 'Lincoln') }

          it 'responds with 200 and an empty array' do
            expect(subject.status).to eq 200
            expect(subject.body).to eq '[]'
          end
        end
      end

      describe 'price_min' do
        let(:params) { super().merge!(price_min: 5000) }
        let(:expected_car) { audi_car }

        it_behaves_like 'correct response'
      end

      describe 'price_max' do
        let(:params) { super().merge!(price_max: 4000) }
        let(:expected_car) { bmw_car }

        it_behaves_like 'correct response'
      end
    end
  end
end
