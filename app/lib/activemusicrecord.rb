require_relative "../../config/environment.rb"

def run
    cli = CLI.new
    cli.app_runner
end

class CLI

    attr_accessor :user, :playlist
    
    def initialize
        @prompt = TTY::Prompt.new
        @user = nil
        @playlist = nil
        @font = TTY::Font.new(:doom)
        @pastel = Pastel.new
        @api = API.new
    end
    
    ################# APP RUNNER ##############################################
    
    def app_runner
        puts "\n"
        puts @pastel.blue(@font.write("* ActiveMusicRecords *"))
        run_initial_menu
    end
    
    
    ################# MENU RUNNERS ##############################################
    
    def run_initial_menu
        puts "\n********** LOGIN MENU **********"
        puts "\n"
        initial_menu_input = initial_menu_choices
        
        case initial_menu_input
        when "Log in"
            log_in
        when "Sign up"
            sign_up
        when "Exit"
            good_bye_message
            exit
        end 
    end
    
    def run_home_menu
        puts "\n********** HOME MENU **********"
        puts "\n"
        home_menu_input = home_menu_choices

        case home_menu_input
        when "Global Top 5 Songs"
            global_top_5_songs
        when "Create new playlist"
            create_playlist
        when "Open existing playlist"
            open_existing_playlist
        when "Delete existing playlist"
            delete_playlist
        when "Listen to a song"
            listen_to_a_song
        when "Settings"
            run_settings_menu
        when "Log out"
            log_out_message
        end
    end

    def run_settings_menu
        puts "\n********** SETTINGS MENU **********"
        puts "\n"
        input = settings_menu_choices
        case input
        when "Change Password"
            change_password
        when "Delete my account"
            delete_account
        when "Return to Home Menu"
            run_home_menu
        end
    end

    def run_playlist_menu
        puts "\n********** PLAYLIST MENU **********"
        puts "\n"
        playlist_menu_input = playlist_menu_choices

        case playlist_menu_input
        when "Add a new song"
            add_song
        when "Delete an existing song"
            delete_song
        when "Play an existing song"
            play_song
        when "Return to Home Menu"
            run_home_menu
        when "Log out"
            log_out_message
        end   
    end

    ################# MENU CHOICES ##############################################

    def initial_menu_choices
        @prompt.select("What would you like to do?", ["Log in", "Sign up", "Exit"], per_page: 10)
    end

    def home_menu_choices
        @prompt.select("What would you like to do?", 
            ["Global Top 5 Songs", "Create new playlist", "Open existing playlist", "Delete existing playlist", "Listen to a song", "Settings", "Log out"], per_page: 10)
    end

    def settings_menu_choices
        @prompt.select("\nWhat would you like to do?", ["Change Password", "Delete my account", "Return to Home Menu"], per_page: 10)
    end
    
    def playlist_menu_choices
        @prompt.select("What would you want to do in this playlist?",
            ["Add a new song", "Delete an existing song", "Play an existing song", "Return to Home Menu", "Log out"], per_page: 10)
    end

    ################# INTIAL MENU METHODS ##############################################
    
    def log_in
        username = @prompt.ask("Enter username to log in:", required: true)
        password = @prompt.mask("Enter your password:", required: true)
        if !User.find_by(name: username, password: password)
            puts "\nIncorrect username or password!".colorize(:red)
            run_initial_menu
        else
            @user = User.find_by(name: username)
            puts "\nSuccesful log in! Welcome, #{@user.name}!".colorize(:green)
            run_home_menu
        end
    end


    def sign_up
        username = @prompt.ask("Enter username to sign up:", required: true)
        if User.find_by(name: username)
            puts "\nUsername '#{username}' already exists!".colorize(:red)
        else
            password = check_password_valid
            if password != "incorrect password"
                puts "\nUser '#{username}' created successfully!".colorize(:green)
                @user = User.create(name: username, password: password)
                run_home_menu
            end
        end
        run_initial_menu
    end


    ################# HOME MENU METHODS ##############################################

    def global_top_5_songs
        Song.display_global_top_5
        run_home_menu
    end

    def create_playlist
        playlist_name = @prompt.ask("Enter the name of your playlist:", required: true)
        @user.create_playlist(playlist_name)
        @user = User.find(@user.id)
        puts "\nPlaylist '#{playlist_name}' created successfully".colorize(:green)
        run_home_menu
    end

    def display_playlists(action)
        puts "These, are your existing playlists:"
        playlist_selection = @prompt.select("Select the playlist you want to #{action}:", @user.playlists_names, per_page: 10)
        @user.playlists.find_by(title: playlist_selection)
    end

    def open_existing_playlist
        if !@user.playlists.empty?
            @playlist = display_playlists("open")
            run_playlist_menu
        else
            puts "\nNo existing playlists".colorize(:red)
            run_home_menu
        end
    end

    def delete_playlist
        if !@user.playlists.empty?
            @playlist = display_playlists("delete").destroy
            @user = User.find(@user.id)
            puts "\nPlaylist '#{@playlist.title}' deleted successfuly".colorize(:green)
            run_home_menu  
        else
            puts "\nNo existing playlists".colorize(:red)
            run_home_menu
        end
    end 

    def listen_to_a_song
        song_chosen = choose_song("search", "listen to")
        puts "\n'#{song_chosen[:title]}' by '#{song_chosen[:artist]}' playing, enjoy!".colorize(:blue)
        song_to_listen = Song.find_or_create_by(song_chosen)
        song_to_listen.increase_times_listened
        Launchy.open("#{song_chosen[:preview]}")
        run_home_menu
    end

    ################# SETTING MENU METHODS ##############################################
    
    def check_password_valid
        new_password = @prompt.mask("Enter new password:", required: true) 
        confirm_new_password = @prompt.mask("Confirm new password:", required: true)
        if new_password == confirm_new_password
            new_password
        else
            puts "\nNew password confirmation does not match new password".colorize(:red)
            "incorrect password"
        end
    end

    def change_password
        current_password = @prompt.mask("Enter current password:", required: true)
        
        if current_password == @user.password
            password = check_password_valid
                if password != "incorrect password"
                    @user = User.update(@user.id, password: password)
                    puts "\nPassword changed successfully!".colorize(:green)
                end
        else
            puts ("\nIncorrect password").colorize(:red)
        end
        run_settings_menu
    end

    def delete_account
        check = @prompt.no?("Are you sure you want to delete your account?")
        case check
        when false
            User.find(@user.id).destroy
            puts ("\nYour account has been deleted :(").colorize(:green)
            run_initial_menu
        else
            run_settings_menu
        end
    end

    ################  SONG SEARCH API #####################################################

    def format_song_list(song_list)
        song_list.map do |song|
            "Title: #{song[:title]} - Artist: #{song[:artist]} - Album: #{song[:album]}"
        end
    end

    def choose_song(action1, action2)
        song_name = @prompt.ask("Enter the song you want to #{action1}:", required: true)
        song_list = @api.song_search(song_name)
        if !song_list.empty?
            formatted_song_list = format_song_list(song_list)
            song_selection = @prompt.select("Select the song you want to #{action2}:", formatted_song_list, per_page: 10)
            song_index = formatted_song_list.find_index(song_selection) 
            song_list[song_index]
        else
            puts "\nSong '#{song_name}' not found, please try another one".colorize(:red)
            choose_song(action1, action2)
        end
    end

    ########################### PLAYLIST MENU METHODS #########################################


    def add_song
        song_chosen = choose_song("add", "add")
        song_instance = Song.find_or_create_by(song_chosen)
        PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: @playlist.id)
        @playlist = @user.playlists.find(@playlist.id)
        puts "\n Song '#{song_chosen[:title]}' by '#{song_chosen[:artist]}' added to your playlist '#{playlist.title}'".colorize(:green)
        run_playlist_menu
    end

    def delete_song
        if !@playlist.songs.empty?
            song_selection = @prompt.select("Select the song you want to delete:", @playlist.list_songs, per_page: 10)
            song_instance = Song.find(song_selection)
            PlaylistSong.find_by(song_id: song_instance.id, playlist_id: @playlist.id).destroy
            @playlist = @user.playlists.find(@playlist.id)
            puts "\nSong '#{song_instance.title}' by '#{song_instance.artist}' deleted from the playlist '#{playlist.title}'".colorize(:green)
        else
            puts "\nYou have no songs in playlist '#{@playlist.title}'".colorize(:red)
        end
        run_playlist_menu
    end

    def play_song
        if !@playlist.songs.empty?
            song_to_play = @prompt.select("Select the song that you want to play", @playlist.list_songs, per_page: 10)
            song_instance = Song.find(song_to_play)
            puts "\n'#{song_instance.title}' by '#{song_instance.artist}' playing, enjoy!".colorize(:blue)
            song_instance.increase_times_listened
            Launchy.open(song_instance[:preview])
        else
            puts "\nYou have no songs in playlist '#{@playlist.title}'".colorize(:red)
        end
        run_playlist_menu
    end

    ################# EXIT METHOD ##############################################

    def log_out_message
        puts "\nYou have been logged out successfully".colorize(:green)
        run_initial_menu
    end

    def good_bye_message
        puts "\n"
        puts @pastel.blue(@font.write("- Good Bye -"))
    end
end