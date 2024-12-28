class AiSuggestionsService
  def initialize(user)
    @user = user
  end

  def call
    @user.ai_car_suggestions
  rescue HTTP::TimeoutError, Errors::Api::BadResponse
    AiSuggestionsJob.perform_later @user.id
    []
  end
end
