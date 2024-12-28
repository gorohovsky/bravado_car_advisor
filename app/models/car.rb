class Car < ApplicationRecord
  belongs_to :brand

  validates :model, presence: true
  validates :model, uniqueness: { scope: :brand }
  validates :price, numericality: { only_integer: true, greater_than: 0 }

  HUMAN_LABEL_NAMES = { 1 => 'perfect_match', 0 => 'good_match', -1 => nil }.freeze
end
