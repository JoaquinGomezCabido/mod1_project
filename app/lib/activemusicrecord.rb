require_relative "../../config/environment.rb"


class CLI
    
    attr_accessor :user, :playlist
    
    def initialize
        @user = nil
        @playlist = nil
    end
    
    ################# APP RUNNER ##############################################
    
    def app_runner
        puts "********** Welcome to ActiveMusicRecords **********"
        run_initial_menu
    end
        
        
    ################# INITIAL MENU RUNNER ##############################################

    def run_initial_menu
        print_initial_menu
        input = gets.chomp
        
        case input
        when "1"
            log_in
            run_home_menu
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

    def print_initial_menu
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
            @user = User.find_by(name: username)
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


    ################# HOME MENU ##############################################
    def run_home_menu
        print_home_menu
        home_menu_input = gets.chomp

        case home_menu_input
        when "1"
            puts "\nEnter the name of your playlist:"
            playlist_name = gets.chomp
            @user.create_playlist(playlist_name)
            @user = User.find(@user.id)
            run_home_menu
        when "2"
            puts "\nThese, are your existing playlists:"
            @user.print_playlists
            puts "\nPlease, select the playlist you want to open:"
            playlist_number = gets.chomp.to_i
            @playlist = @user.playlists[playlist_number - 1]
            run_playlist_menu
        when "3"
            puts "\nThese, are your existing playlists:"
            @user.print_playlists
            puts "\nPlease, select the playlist you want to delete:"
            playlist_number = gets.chomp.to_i
            @user.playlists[playlist_number - 1].destroy
            @user = User.find(@user.id)
            run_home_menu
        when "4"
            puts "\nEnter the song you want to search:"
            song_name = gets.chomp
            song_search(song_name)
        when "5"
            exit
        else
            puts "\nUnkown option!"
            run_home_menu
        end
    end

    def print_home_menu
        puts "\nWhat would you like to do?"
        puts "1. Create new playlist"
        puts "2. Open existing playlist"
        puts "3. Delete existing playlist"
        puts "4. Just search for a song"
        puts "5. Exit"
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

    # ########################## PLAYLIST MENU #############################################

    def run_playlist_menu
        print_playlist_menu
        playlist_menu_input = gets.chomp

        case playlist_menu_input
            when "1"
                puts "\nEnter the song you want to add:"
                song_name = gets.chomp
                song_list = song_search(song_name)
                puts "\nPlease, select the song you want to add:"
                song_number = gets.chomp.to_i
                song = song_list[song_number - 1]
                song_instance = Song.find_or_create_by(title: song["title"])
                PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: @playlist.id)
                @playlist = @user.playlists.find(@playlist.id)
                run_playlist_menu
            when "2"
                puts "\nPlease, select the song you want to delete:"
                @playlist.print_songs
                song_number = gets.chomp.to_i
                song_id_to_delete = @playlist.songs[song_number - 1].id
                PlaylistSong.find_by(playlist_id: @playlist.id, song_id: song_id_to_delete).destroy
                @playlist = @user.playlists.find(@playlist.id)
                run_playlist_menu
            when "3"
                puts "\nThese are the current songs in this playlist:"
                @playlist.print_songs
                run_playlist_menu
            when "4"
                run_home_menu
            when "5"
                exit
            else
                puts "\nUnkown option!"
                run_playlist_menu
            end   
    end

    def print_playlist_menu
        puts "\nWhat would you want to do in this playlist?"
        puts "1. Add a new song"
        puts "2. Delete an existing song"
        puts "3. Show all the songs"
        puts "4. Return to Home Menu"
        puts "5. Exit"
    end
end

cli = CLI.new
cli.app_runner

binding.pry
0