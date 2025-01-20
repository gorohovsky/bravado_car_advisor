module SuggestionsApi
  class ResponseValidator
    include Errors::ExternalApi

    VALIDATORS = {
      'response' => ->(response) { response.is_a?(Array) },
      'entry' => ->(entry) { entry.is_a?(Hash) && entry.size == 2 },
      'car_id' => ->(car_id) { car_id.is_a?(Integer) && car_id.positive? },
      'rank_score' => ->(rank_score) { rank_score.is_a?(Float) && rank_score >= 0 }
    }.freeze

    def initialize(response)
      @response = response
    end

    def validate!
      validate_response(@response)
      @response.each do |entry|
        validate_entry(entry)
        validate_car_id(entry['car_id'])
        validate_rank_score(entry['rank_score'])
      end
    end

    private

    VALIDATORS.each do |element, validator|
      define_method("validate_#{element}") do |value|
        raise MalformedResponse.new(element, value) unless validator.call(value)
      end
    end
  end
end
