require_relative "../../config/environment.rb"


class CLI

    attr_accessor :user, :playlist
    
    def initialize
        @prompt = TTY::Prompt.new
        @user = nil
        @playlist = nil
    end
    
    ################# APP RUNNER ##############################################
    
    def app_runner
        puts "\n*************** Welcome to ActiveMusicRecords ***************".colorize(:blue)
        run_initial_menu
    end
    
    
    ################# INITIAL MENU RUNNER ##############################################
    
    def run_initial_menu
        initial_menu_input = initial_menu_choices
        
        case initial_menu_input
        when "Log in"
            log_in
            run_home_menu
        when "Sign up"
            sign_up
            run_initial_menu
        when "Exit"
            exit
        end 
    end

    def initial_menu_choices
        @prompt.select("\nWhat would you like to do?", ["Log in", "Sign up", "Exit"])
    end
    
    def log_in
        username = @prompt.ask("Enter username to log in:")
        password = @prompt.mask("Enter your password")
        if !User.find_by(name: username, password: password)
            puts "\nIncorrect username or password!".colorize(:red)
            run_initial_menu
        else
            @user = User.find_by(name: username)
            puts "\nSuccesful log in!".colorize(:green)
        end
    end


    def sign_up
        username = @prompt.ask("Enter username to sign up:")
        if User.find_by(name: username)
            puts "\nUsername already exists!".colorize(:red)
            run_initial_menu
        else
            password = @prompt.mask("Set your password:")
            puts "\nUser created successfully!!".colorize(:green)
            User.create(name: username, password: password)
        end
    end


    ################# HOME MENU ##############################################
    def run_home_menu
        home_menu_input = home_menu_choices

        case home_menu_input
        when "Create new playlist"
            playlist_name = @prompt.ask("Enter the name of your playlist:")
            @user.create_playlist(playlist_name)
            @user = User.find(@user.id)
            run_home_menu
        when "Open existing playlist"
            if @user.playlists
                puts "These, are your existing playlists:"
                playlist_selection = @prompt.select("Select the playlist you want to open:", @user.playlists_names)
                @playlist = @user.playlists.find_by(title: playlist_selection)
                run_playlist_menu
            else
                puts "\nNo existing playlists".colorize(:red)
                run_home_menu
            end
        when "Delete existing playlist"
            if @user.playlists
                puts "These, are your existing playlists:"
                playlist_selection = @prompt.select("Select the playlist you want to delete:", @user.playlists_names)
                @playlist = @user.playlists.find_by(title: playlist_selection).destroy
                @user = User.find(@user.id)
                run_home_menu
            else
                puts "\nNo existing playlists".colorize(:red)
                run_home_menu
            end
        when "Listen to a song"
            song_name = @prompt.ask("Enter the song you want to search:")
            song_list = song_search(song_name)
            formatted_song_list = format_song_list(song_list)
            song_selection = @prompt.select("Select the song you want to listen to:", formatted_song_list)
            song_index = formatted_song_list.find_index(song_selection) 
            puts "\n'#{song_list[song_index][:title]}' playing, enjoy!".colorize(:blue)
            run_home_menu
        when "Exit"
            exit
        end
    end

    def home_menu_choices
        @prompt.select("What would you like to do?", 
            ["Create new playlist", "Open existing playlist", "Delete existing playlist", "Listen to a song", "Exit"])
    end

    def song_search(song_name)
        response = JSON.parse(open("https://api.deezer.com/search?q=track:#{song_name}").read)["data"][0...5]
        formatted_response = response.map do |song|
            {title: "#{song["title"]}", artist: "#{song["artist"]["name"]}", album: "#{song["album"]["title"]}"}
        end
    end

    def format_song_list(song_list)
        song_list.map do |song|
            "Title: #{song[:title]} - Artist: #{song[:artist]} - Album: #{song[:album]}"
        end
    end

    ########################### PLAYLIST MENU #############################################

    def run_playlist_menu
        playlist_menu_input = playlist_menu_choices

        case playlist_menu_input
            when "Add a new song"
                song_name = @prompt.ask("Enter the song you want to add:")
                song_list = song_search(song_name)
                formatted_list = format_song_list(song_list)
                song_selection = @prompt.select("Select the song you want to add:", formatted_list)
                song_index = formatted_list.find_index(song_selection) 
                song_instance = Song.find_or_create_by(title: song_list[song_index][:title])
                PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: @playlist.id)
                @playlist = @user.playlists.find(@playlist.id)
                run_playlist_menu
            when "Delete an existing song"
                if !@playlist.songs.empty?
                    song_selection = @prompt.select("Select the song you want to delete:", @playlist.song_names)
                    song_id_to_delete = @playlist.songs.find_by(title: song_selection)
                    PlaylistSong.find_by(playlist_id: @playlist.id, song_id: song_id_to_delete).destroy
                    @playlist = @user.playlists.find(@playlist.id)
                else
                    puts "\nYou have no songs in this playlist".colorize(:red)
                end
                run_playlist_menu
            when "Play an existing song"
                if !@playlist.songs.empty?
                    song_to_play = @prompt.select("Select the song that you want to play", @playlist.song_names)
                    puts "\n'#{song_to_play}' playing, enjoy!".colorize(:blue)
                else
                    puts "\nYou have no songs in this playlist".colorize(:red)
                end
                run_playlist_menu
            when "Return to Home Menu"
                run_home_menu
            when "Exit"
                exit
            end   
    end

    def playlist_menu_choices
        @prompt.select("What would you want to do in this playlist?",
            ["Add a new song", "Delete an existing song", "Play an existing song", "Return to Home Menu", "Exit"])
    end
end

cli = CLI.new
cli.app_runner

binding.pry
0