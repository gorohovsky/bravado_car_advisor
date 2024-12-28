module CarRecommendationsHelper
  HUMAN_LABEL_NAMES = { 1 => 'perfect_match', 0 => 'good_match', -1 => nil }.freeze

  def label_to_human(numeric_label)
    HUMAN_LABEL_NAMES[numeric_label]
  end

  def format_rank(rank)
    rank == CarRecommendationService::NULL_SUBSTITUTE ? nil : rank
  end
end
