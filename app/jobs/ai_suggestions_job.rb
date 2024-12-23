class AiSuggestionsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5
  sidekiq_retry_in { |retry_count| 10 * (retry_count + 1) }

  def perform(user_id)
    User.find(user_id).ai_car_suggestions
  end
end
