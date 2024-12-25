class Brand < ApplicationRecord
  has_many :cars, dependent: :destroy
  # TODO: replace associations if no operations on the join table
  # has_and_belongs_to_many :users, join_table: :user_preferred_brands
  has_many :user_preferred_brands, dependent: :destroy
  has_many :users, through: :user_preferred_brands

  validates :name, presence: true
  validates :name, uniqueness: true
end
