json.id car.id
json.brand do
  json.id car.brand_id
  json.name car.brand_name
end
json.price car.price
json.rank_score format_rank car.rank
json.model car.model
json.label label_to_human car.label
