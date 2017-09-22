class CreateConcerts < ActiveRecord::Migration[5.1]
  def change
    create_table :concerts do |t|
      t.string :name
      t.string :venue
      t.date :date
      t.string :time
      t.string :seatmap
      t.string :purchase

      t.timestamps
    end
  end
end
