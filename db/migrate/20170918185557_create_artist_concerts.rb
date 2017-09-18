class CreateArtistConcerts < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_concerts do |t|
      t.integer :artist_id
      t.integer :concert_id
      t.timestamps
    end
  end
end
