class CreateConcerts < ActiveRecord::Migration[5.1]
  def change
    create_table :concerts do |t|
      t.string :name
      t.string :location
      t.datetime :date
      t.timestamps
    end
  end
end
