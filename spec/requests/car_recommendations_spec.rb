require 'rails_helper'

describe 'CarRecommendations', type: :request do
  describe 'GET /index' do
    let(:brand) { create(:brand) }
    let(:user) { create(:user, preferred_brands: [brand]) }
    let(:params) { { user_id: user.id } }

    after { Faker::UniqueGenerator.clear }

    subject do
      get car_recommendations_url, params: params
      response
    end

    shared_context 'car matching preferred brand' do
      let!(:car_brand_match) { create(:car, price: 5000, brand:) }
    end

    shared_context 'car matching preferred brand and price' do
      let!(:car_brand_price_match) { create(:car, brand:) }
    end

    shared_examples 'response with correct ordering' do
      it 'responds with 200 and data in correct order' do
        expect(subject.status).to eq 200

        expect(JSON.parse(subject.body)).to eq(
          cars_in_correct_order.map!.with_index do |car, i|
            {
              'id' => car.id,
              'brand' => {
                'id' => car.brand.id,
                'name' => car.brand.name
              },
              'price' => car.price,
              'model' => car.model,
              'label' => labels_in_correct_order[i]
            }
          end
        )
      end
    end

    context 'when cars match user preferred price' do
      let!(:car) { create(:car) }
      include_context 'car matching preferred brand'
      include_context 'car matching preferred brand and price'

      let(:cars_in_correct_order) { [car_brand_price_match, car_brand_match, car] }
      let(:labels_in_correct_order) { %w(perfect_match good_match null) }

      it_behaves_like 'response with correct ordering'
    end

    context 'when cars match user preferred brand, but not price' do
      let!(:car) { create(:car) }
      include_context 'car matching preferred brand'

      let(:cars_in_correct_order) { [car_brand_match, car] }
      let(:labels_in_correct_order) { %w(good_match null) }

      it_behaves_like 'response with correct ordering'
    end

    context 'when no cars match preferred brands' do
      let!(:cars) { create_list(:car, 3) }
      let(:cars_in_correct_order) { cars }
      let(:labels_in_correct_order) { ['null'] * 3 }

      it_behaves_like 'response with correct ordering'
    end

    describe 'pagination' do
      let!(:cars) { create_list(:car, 21) }

      shared_examples 'correct response' do |entries_number|
        it 'returns correct number of entries per page' do
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

    describe 'request parameters' do
      let!(:bmw_car) { create(:car, :with_brand, brand_name: 'BMW', price: 4000) }
      let!(:audi_car) { create(:car, :with_brand, brand_name: 'Audi', price: 5000) }

      shared_examples 'correct response' do
        it 'responds with 200 and cars matching the criteria' do
          expect(subject.status).to eq 200
          JSON.parse(subject.body).tap do |payload|
            expect(payload.size).to eq 1
            expect(payload.first).to eq(
              'id' => expected_car.id,
              'brand' => {
                'id' => expected_car.brand.id,
                'name' => expected_car.brand.name
              },
              'price' => expected_car.price,
              'model' => expected_car.model,
              'label' => 'null'
            )
          end
        end
      end

      describe 'query' do
        context 'when supplied full brand name' do
          let(:params) { super().merge!(query: 'BMW') }
          let!(:expected_car) { bmw_car }

          it_behaves_like 'correct response'
        end

        context 'when supplied partial brand name' do
          let(:params) { super().merge!(query: 'Au') }
          let!(:expected_car) { audi_car }

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
