require_relative "../../config/environment.rb"

def greeting
    puts "Welcome to ActiveMusicRecords"
end

################ INITIAL MENU ##############################################
def initial_menu
    puts "What would you like to do?" 
    puts "1. Log in"
    puts "2. Sign up"
    puts "3. Exit"
    input = gets.chomp
    initial_logic(input)
end

def log_in
    puts "Enter username to log in:"
    username = gets.chomp
    if !User.find_by(name: username)
        puts "Username not found!"
        log_in
    else
        user = User.find_by(name: username)
    end
    home_menu(user)
end


def sign_up
    puts "Enter username to sign up:"
    username = gets.chomp
    if User.find_by(name: username)
        puts "Username already exists!"
        sign_up
    else
        User.create(name: username)
    end
    log_in
end

def initial_logic(input)
    case input
    when "1"
        log_in
    when "2"
        sign_up
    when "3"
        exit
    else
        puts "Unkown option!"
        initial_menu
    end
end

################ HOME MENU ##############################################
def home_menu(user)
    puts "What would you like to do?"
    puts "1. Create new playlist"
    puts "2. Open existing playlist"
    puts "3. Just search for a song"
    puts "4. Exit"
    input = gets.chomp
    home_logic(input, user)
end

def home_logic(input, user)
    case input
    when "1"
        puts "Enter the name of your playlists:"
        name = gets.chomp
        user.create_playlist(name)
        home_menu(user)
    when "2"
        i = 1
        user.playlists.each do |playlist|
            puts "#{i}. #{playlist.title}"
            i += 1
        end
        puts "Please, select the playlist you want to open:"
        playlist_number = gets.chomp.to_i
        playlist_menu(user.playlists[playlist_number - 1])
    when "3"
        puts "Enter the song you want to search:"
        song = gets.chomp
        song_search(song)
    when "4"
        exit
    else
        puts "Unkown option!"
        home_menu
    end
end

def song_search(song)
    response = JSON.parse(open("https://api.deezer.com/search?q=track:#{song}").read)["data"][0...5]
    i = 1
    test = response.each do |song|
        puts "#{i}. Title: #{song["title"]} - Artist: #{song["artist"]["name"]} - Album: #{song["album"]["title"]}"
        puts "-------------------------------------------------------"
        i += 1
    end
end

########################## PLAYLIST MENU #############################################

def playlist_menu(playlist)
    puts "What would you want to do in this playlist?"
    puts "1. Add a new song"
    puts "2. Delete an existing song"
    puts "3. Show all the songs"
    ##### 4. return
    puts "5. Exit"
    input = gets.chomp
    playlist_logic(input, playlist)
end

def playlist_logic(input, playlist)
    case input
    when "1"
        puts "Enter the song you want to add:"
        song_name = gets.chomp
        list = song_search(song_name)
        puts "Please, select the song you want to add:"
        song_number = gets.chomp.to_i
        song = list[song_number - 1]
        song_instance = Song.find_or_create_by(title: song["title"])
        PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: playlist.id)
    when "2"
        i = 1
        playlist.songs.each do |song|
            puts "#{i}. Title: #{song.title}"
            i += 1
        end
        puts "Please, select the song you want to delete:"
        song_number = gets.chomp.to_i
        song_id_to_delete = playlist.songs[song_number - 1].id
        PlaylistSong.find_by(playlist_id: playlist.id, song_id: song_id_to_delete).destroy
    when "3"
        i = 1
        playlist.songs.each do |song|
            puts "#{i}. Title: #{song.title}"
            i += 1
        end
    when "5"
        exit
    else
        puts "Unkown option!"
        home_menu
    end   
end



binding.pry
0