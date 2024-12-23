require 'rails_helper'

describe AiSuggestionsJob, type: :job do
  let!(:user) { create(:user) }
  let(:suggestions) { ['an AI suggestion'] }

  subject { described_class.perform_now(user.id) }

  it 'returns AI car suggestions for the specified user' do
    expect_any_instance_of(User).to receive(:ai_car_suggestions).and_return suggestions
    expect(subject).to eq suggestions
  end
end
