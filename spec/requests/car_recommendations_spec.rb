require 'rails_helper'

describe 'CarRecommendations', type: :request do
  describe 'GET /index' do
    let!(:cars) { create_list(:car, 20) }
    let!(:extra_car) { create(:car) }

    subject do
      get car_recommendations_url, params: params
      response
    end

    after { Faker::UniqueGenerator.clear }

    shared_examples 'correct response' do
      it 'returns correct number of entries per page' do
        expect(JSON.parse(subject.body).size).to eq expected_cars.count
      end

      it 'responds with correct data and status' do
        expect(subject.status).to eq 200

        expect(JSON.parse(subject.body)).to eq(
          expected_cars.map do |car|
            {
              'id' => car.id,
              'brand' => {
                'id' => car.brand.id,
                'name' => car.brand.name
              },
              'price' => car.price,
              'model' => car.model
            }
          end
        )
      end
    end

    context 'when page is not provided' do
      let(:params) { {} }
      let(:expected_cars) { cars }
      it_behaves_like 'correct response'
    end

    context 'when page is provided' do
      let(:params) { { page: 2 } }
      let(:expected_cars) { [extra_car] }
      it_behaves_like 'correct response'
    end
  end
end
