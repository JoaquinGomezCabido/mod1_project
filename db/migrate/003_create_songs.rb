class CreateSongs < ActiveRecord::Migration[4.2]
    def change
        create_table :songs do |t|
            t.string :title
            t.string :artist
            t.string :album
            t.string :preview
            t.integer :times_played
        end
    end
end
