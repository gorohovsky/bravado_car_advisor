module CarRecommendationsHelper
  def label_to_human(numeric_label)
    Car::HUMAN_LABEL_NAMES[numeric_label]
  end
end
