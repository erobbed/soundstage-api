class AddStateToConcerts < ActiveRecord::Migration[5.1]
  def change
    add_column :concerts, :state, :string
  end
end
