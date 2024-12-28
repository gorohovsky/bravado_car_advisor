module CarRecommendationsHelper
  def label_to_human(numeric_label)
    Car::HUMAN_LABEL_NAMES[numeric_label]
  end

  def format_rank(rank)
    rank == -1 ? nil : rank
  end
end
