# mod1_project
Active Music Record

The Active Music Record app is a CLI application which requires the user to sign up or log in. Once logged in, the user is able to listen to a song or make his own playlists.

Below is a flowchart of the full Active Music Record functionalities: 

![Alt text](https://github.com/JoaquinGomezCabido/mod1_project/blob/master/Mod1%20project%20-%20Active%20Music%20Record%20-%20Flatiron.jpeg)

Active Music Record is made of 4 classes: User, Playlist, Song and PlaylistSong.

- A user has many playlists
- A playlist has many playlist_songs and many songs through playlist_songs. A playlist belongs to a user
- A song has many playlist_songs and many playlists through playlist_songs.
- A playlist_song belongs to a playlist and a song.

The classes use a database made of 4 tables: users, playlists, songs and playlistsongs

- users has a name and a password
- playlists has a title and a user id
- songs has a title, an artist, an album, a preview and times played.
- playlistsongs has a playlist id and a song id.

The CLI application uses gems to enhance the user experience. The gems used are:

- gem 'json': allows the user to search for song information through an API. The API used is provided by Deezer ( https://www.deezer.com/en/).
- gem 'tty-prompt': allows the application to use a larger variety of prompts like yes/no, hide answers like passwords, ..etc
- gem 'colorize': allows to change the color for some outputs. The color green is used when an action was successful, red    when it failed and blue when information is returned such as details of the song playing.
- gem 'launchy': allows to open the url of the song preview if the user wants to listen to a song.
- gem 'tty-font': allows to format text with different fonts for the welcome and exit message.
- gem 'pastel': allows to change the color of the welcome and exit messsage.

To run the Active Music Record app, type "ruby app/bin/activemusicrecord" in your terminal.
