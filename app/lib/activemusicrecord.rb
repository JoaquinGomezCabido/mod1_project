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
    end
    
    ################# APP RUNNER ##############################################
    
    def app_runner
        puts "\n"
        puts @pastel.blue(@font.write("* ActiveMusicRecords *"))
        run_initial_menu
    end
    
    
    ################# INITIAL MENU RUNNER ##############################################
    
    def run_initial_menu
        puts "\n********** LOGIN MENU **********"
        puts "\n"
        initial_menu_input = initial_menu_choices
        
        case initial_menu_input
        when "Log in"
            log_in
            run_home_menu
        when "Sign up"
            sign_up
            run_initial_menu
        when "Exit"
            good_bye_message
            exit
        end 
    end

    def initial_menu_choices
        @prompt.select("What would you like to do?", ["Log in", "Sign up", "Exit"])
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
        puts "\n********** HOME MENU **********"
        puts "\n"
        home_menu_input = home_menu_choices

        case home_menu_input
        when "Create new playlist"
            playlist_name = @prompt.ask("Enter the name of your playlist:")
            @user.create_playlist(playlist_name)
            @user = User.find(@user.id)
            run_home_menu
        when "Open existing playlist"
            if !@user.playlists.empty?
                @playlist = display_playlists("open")
                run_playlist_menu
            else
                puts "\nNo existing playlists".colorize(:red)
                run_home_menu
            end
        when "Delete existing playlist"
            if !@user.playlists.empty?
                @playlist = display_playlists("delete").destroy
                @user = User.find(@user.id)
                puts "\nPlaylist deleted successfuly".colorize(:green)
                run_home_menu
            else
                puts "\nNo existing playlists".colorize(:red)
                run_home_menu
            end
        when "Listen to a song"
            song_chosen = choose_song("search", "listen to")
            puts "\n'#{song_chosen[:title]}' playing, enjoy!".colorize(:blue)
            Launchy.open("#{song_chosen[:preview]}")
            run_home_menu
        when "Settings"
            settings_menu
        when "Exit"
            good_bye_message
            exit
        end
    end

    def display_playlists(action)
        puts "These, are your existing playlists:"
        playlist_selection = @prompt.select("Select the playlist you want to #{action}:", @user.playlists_names)
        @user.playlists.find_by(title: playlist_selection)
    end

    def home_menu_choices
        @prompt.select("What would you like to do?", 
            ["Create new playlist", "Open existing playlist", "Delete existing playlist", "Listen to a song", "Settings", "Exit"])
    end

    def settings_menu
        puts "\n********** SETTINGS MENU **********"
        puts "\n"
        input = @prompt.select("\nWhat would you like to do?", ["Change Password", "Delete my account", "Return to Home Menu"])
        case input
        when "Change Password"
            change_password
            run_home_menu
        when "Delete my account"
            delete_account
            run_home_menu
        when "Return to Home Menu"
            run_home_menu
        end
    end
    
    def change_password
        current_password = @prompt.mask("Enter current password:")
        
        case current_password
        when @user.password
            set_new_password
            run_home_menu
        else
            puts ("\nIncorrect password").colorize(:red)
            settings_menu
        end
    end

    def set_new_password
        new_password = @prompt.mask("Enter new password") 
        confirm_new_password = @prompt.mask("Confirm new password")
        
        case new_password
        when confirm_new_password
            puts "\nPassword changed successfully!".colorize(:green)
            @user = User.update(@user.id, :password => new_password)
        else 
            puts "\nNew password confirmation does not match new password".colorize(:red)
            settings_menu
        end
    end

    def delete_account
        check = @prompt.yes?("Are you sure you want to delete your account?")
        case check
        when true
            User.find(@user.id).destroy
            puts ("\nYour account has been deleted :(").colorize(:green)
            run_initial_menu
        else
            run_home_menu
        end
    end

    ################  SONG SEARCH API #####################################################

    def song_search(song_name)
        response = JSON.parse(open("https://api.deezer.com/search?q=#{song_name}").read)["data"][0...5]
        if response
            formatted_response = response.map do |song|
                {title: "#{song["title"]}", artist: "#{song["artist"]["name"]}", album: "#{song["album"]["title"]}", preview: "#{song["preview"]}"}
            end
        else
            formatted_response = nil
        end
    end

    def format_song_list(song_list)
        song_list.map do |song|
            "Title: #{song[:title]} - Artist: #{song[:artist]} - Album: #{song[:album]}"
        end
    end

    def choose_song(action1, action2)
        song_name = @prompt.ask("Enter the song you want to #{action1}:")
        song_list = song_search(song_name)
        if !song_list.empty?
            formatted_song_list = format_song_list(song_list)
            song_selection = @prompt.select("Select the song you want to #{action2}:", formatted_song_list)
            song_index = formatted_song_list.find_index(song_selection) 
            song_list[song_index]
        else
            puts "\nSong not found, please try another one".colorize(:red)
            choose_song(action1, action2)
        end
    end

    ########################### PLAYLIST MENU #############################################

    def run_playlist_menu
        puts "\n********** PLAYLIST MENU **********"
        puts "\n"
        playlist_menu_input = playlist_menu_choices

        case playlist_menu_input
            when "Add a new song"
                song_chosen = choose_song("add", "add")
                song_instance = Song.find_or_create_by(song_chosen)
                PlaylistSong.find_or_create_by(song_id: song_instance.id, playlist_id: @playlist.id)
                @playlist = @user.playlists.find(@playlist.id)
                run_playlist_menu
            when "Delete an existing song"
                if !@playlist.songs.empty?
                    song_selection = @prompt.select("Select the song you want to delete:", @playlist.song_names)
                    song_id_to_delete = @playlist.songs.find_by(title: song_selection)
                    PlaylistSong.find_by(playlist_id: @playlist.id, song_id: song_id_to_delete).destroy
                    @playlist = @user.playlists.find(@playlist.id)
                    puts "\nSong deleted from the playlist".colorize(:green)
                else
                    puts "\nYou have no songs in this playlist".colorize(:red)
                end
                run_playlist_menu
            when "Play an existing song"
                if !@playlist.songs.empty?
                    song_to_play = @prompt.select("Select the song that you want to play", @playlist.song_names)
                    puts "\n'#{song_to_play}' playing, enjoy!".colorize(:blue)
                    Launchy.open(@playlist.songs.find_by(title: song_to_play)[:preview])
                else
                    puts "\nYou have no songs in this playlist".colorize(:red)
                end
                run_playlist_menu
            when "Return to Home Menu"
                run_home_menu
            when "Exit"
                good_bye_message
                exit
            end   
    end

    def playlist_menu_choices
        @prompt.select("What would you want to do in this playlist?",
            ["Add a new song", "Delete an existing song", "Play an existing song", "Return to Home Menu", "Exit"])
    end

    def good_bye_message
        puts "\n"
        puts @pastel.blue(@font.write("- Good Bye -"))
    end
end