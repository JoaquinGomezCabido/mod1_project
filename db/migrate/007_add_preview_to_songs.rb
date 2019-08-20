class AddPreviewToSongs < ActiveRecord::Migration[4.2]
    def change
        add_column :songs, :preview, :string
    end
end
