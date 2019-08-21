class Playlist < ActiveRecord::Base
    belongs_to :user
    has_many :playlist_songs
    has_many :songs, through: :playlist_songs

    def list_song_attributes
        self.songs.map{|song| {title: song.title, artist: song.artist, album: song.album, preview: song.preview}}
    end

    def formatted_list_song_attributes
        self.songs.map{|song| "'#{song[:title]}' by '#{song[:artist]}'"}
    end
end