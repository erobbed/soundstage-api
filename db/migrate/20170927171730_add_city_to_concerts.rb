class AddCityToConcerts < ActiveRecord::Migration[5.1]
  def change
    add_column :concerts, :city, :string
  end
end
