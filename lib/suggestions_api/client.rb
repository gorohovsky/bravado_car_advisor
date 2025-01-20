module SuggestionsApi
  class Client
    include Errors::ExternalApi

    URL_TEMPLATE = "#{ENV.fetch('AI_SUGGESTIONS_API_URL')}?user_id=%s".freeze
    HEADERS = { 'Accept' => 'application/json' }.freeze
    TIMEOUT = 2

    def initialize(user_id)
      @user_id = user_id
    end

    def perform
      request
      handle_response
    end

    private

    def request
      @response = HTTP.use(logging: { logger: Rails.logger }).headers(HEADERS).timeout(TIMEOUT).get url
    end

    def handle_response
      @response.status.success? ? validate_response(@response.parse) : raise(BadResponse)
    end

    def validate_response(response)
      ResponseValidator.new(response).validate!
    end

    def url
      format(URL_TEMPLATE, @user_id)
    end
  end
end
