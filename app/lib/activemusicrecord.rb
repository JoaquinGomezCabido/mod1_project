require_relative "../../config/environment.rb"

################ APP RUNNER ##############################################

def app_runner
    puts "Welcome to ActiveMusicRecords"
    run_initial_menu
end

################ INITIAL MENU RUNNER ##############################################

def run_initial_menu
    initial_menu
    input = gets.chomp

    case input
    when "1"
        user = log_in
        run_home_menu(user)
    when "2"
        sign_up
        run_initial_menu
    when "3"
        exit
    else
        puts "\nUnkown option!"
        initial_menu
    end 
end

def initial_menu
    puts "\nWhat would you like to do?" 
    puts "1. Log in"
    puts "2. Sign up"
    puts "3. Exit"
end

def log_in
    puts "\nEnter username to log in:"
    username = gets.chomp
    if !User.find_by(name: username)
        puts "\nUsername not found!"
        log_in
    else
        user = User.find_by(name: username)
    end
end


def sign_up
    puts "\nEnter username to sign up:"
    username = gets.chomp
    if User.find_by(name: username)
        puts "\nUsername already exists!"
        sign_up
    else
        puts "\nUser created successfully!!"
        User.create(name: username)
    end

end


################ HOME MENU ##############################################
def run_home_menu(user)
    print_home_menu
    home_menu_input = gets.chomp
    home_menu_logic(home_menu_input, user)
end

def print_home_menu
    puts "\nWhat would you like to do?"
    puts "1. Create new playlist"
    puts "2. Open existing playlist"
    puts "3. Just search for a song"
    puts "4. Exit"
end

def home_menu_logic(home_menu_input, user)
    case home_menu_input
    when "1"
        puts "\nEnter the name of your playlist:"
        playlist_name = gets.chomp
        user.create_playlist(playlist_name)
        home_menu(user)
    when "2"
        puts "\nThese, are your existing playlists:"
        user.print_playlists
        puts "\nPlease, select the playlist you want to open:"
        playlist_number = gets.chomp.to_i
        selected_playlist = user.playlists[playlist_number - 1]
        playlist_menu(selected_playlist, user)
    when "3"
        puts "\nEnter the song you want to search:"
        song_name = gets.chomp
        song_search(song_name)
    when "4"
        exit
    else
        puts "Unkown option!"
        home_menu(user)
    end
end

def song_search(song_name)
    response = JSON.parse(open("https://api.deezer.com/search?q=track:#{song_name}").read)["data"][0...5]
    i = 1
    response.each do |song|
        puts "#{i}. Title: #{song["title"]} - Artist: #{song["artist"]["name"]} - Album: #{song["album"]["title"]}"
        puts "-------------------------------------------------------"
        i += 1
    end
end

########################## PLAYLIST MENU #############################################

def playlist_menu(selected_playlist, user)
    print_playlist_menu
    playlist_menu_input = gets.chomp
    playlist_logic(playlist_menu_input, selected_playlist, user)
end

def print_playlist_menu
    puts "What would you want to do in this playlist?"
    puts "1. Add a new song"
    puts "2. Delete an existing song"
    puts "3. Show all the songs"
    puts "4. Return to Home Menu"
    puts "5. Exit"
end

def playlist_logic(playlist_menu_input, selected_playlist, user)
    case playlist_menu_input
    when "1"
        puts "\nEnter the song you want to add:"
        song_name = gets.chomp
        song_list = song_search(song_name)
        puts "\nPlease, select the song you want to add:"
        song_number = gets.chomp.to_i
        song = song_list[song_number - 1]
        song_instance = Song.find_or_create_by(title: song["title"])
        PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: selected_playlist.id)
    when "2"
        i = 1
        selected_playlist.songs.each do |song|
            puts "#{i}. Title: #{song.title}"
            i += 1
        end
        puts "\nPlease, select the song you want to delete:"
        song_number = gets.chomp.to_i
        song_id_to_delete = selected_playlist.songs[song_number - 1].id
        PlaylistSong.find_by(playlist_id: selected_playlist.id, song_id: song_id_to_delete).destroy
    when "3"
        i = 1
        selected_playlist.songs.each do |song|
            puts "#{i}. Title: #{song.title}"
            i += 1
        end
    when "4"
        home_menu(user)
    when "5"
        exit
    else
        puts "\nUnkown option!"
        playlist_menu(selected_playlist)
    end   
end


binding.pry
0