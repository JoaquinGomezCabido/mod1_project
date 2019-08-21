class Song < ActiveRecord::Base
    has_many :playlist_songs
    has_many :playlists, through: :playlist_songs

    def self.get_global_top_5
        Song.all.order("times_played DESC").limit(5)
    end

    def increase_times_listened
        if self.times_played == nil
            self.update(times_played: 1)
        else 
            self.update(times_played: self.times_played + 1)
        end
    end

    def self.display_global_top_5
        i = 1
        self.get_global_top_5.map do |song|
            puts "#{i}. '#{song.title}' by '#{song.artist}' was played #{song.times_played} times".colorize(:blue)
            i += 1
        end
    end
end