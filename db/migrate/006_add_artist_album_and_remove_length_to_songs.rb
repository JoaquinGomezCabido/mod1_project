class AddArtistAlbumAndRemoveLengthToSongs < ActiveRecord::Migration[4.2]
    def change
        add_column :songs, :artist, :string
        add_column :songs, :album, :string
        remove_column :songs, :length
    end
end
