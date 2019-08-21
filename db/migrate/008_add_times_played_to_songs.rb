class AddTimesPlayedToSongs < ActiveRecord::Migration[4.2]
    def change
        add_column :songs, :times_played, :integer
    end
end
