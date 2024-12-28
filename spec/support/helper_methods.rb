def car_to_hash(car, rank: nil, label: nil)
  {
    'id' => car.id,
    'brand' => {
      'id' => car.brand.id,
      'name' => car.brand.name
    },
    'price' => car.price,
    'rank_score' => rank,
    'model' => car.model,
    'label' => label
  }
end
