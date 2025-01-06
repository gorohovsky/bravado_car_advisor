class AiSuggestionsService
  def initialize(user)
    @user = user
  end

  def call
    @user.ai_car_suggestions
  rescue StandardError => e
    Rails.logger.error e.full_message
    AiSuggestionsJob.perform_later @user.id
    []
  end
end
