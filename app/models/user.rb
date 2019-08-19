class User < ActiveRecord::Base
    has_many :playlists

    def create_playlist(title)
        Playlist.create(title: title, user_id: self.id)
    end
end