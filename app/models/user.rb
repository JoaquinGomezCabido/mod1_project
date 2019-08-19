class User < ActiveRecord::Base
    has_many :playlists

    def create_playlist(title)
        Playlist.create(title: title, user_id: self.id)
    end

    def print_playlists
        i = 1
        self.playlists.each do |playlist|
            puts "#{i}. #{playlist.title}"
            i += 1
        end
    end
end