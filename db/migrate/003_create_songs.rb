class CreateSongs < ActiveRecord::Migration[4.2]
    def change
        create_table :songs do |t|
            t.string :title
            t.integer :length
        end
    end
end
