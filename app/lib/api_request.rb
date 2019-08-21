class API
    def song_search(song_name)
        response = JSON.parse(open("https://api.deezer.com/search?q=#{song_name}").read)["data"][0...10]
        if response
            formatted_response = response.map do |song|
                {title: "#{song["title"]}", artist: "#{song["artist"]["name"]}", album: "#{song["album"]["title"]}", preview: "#{song["preview"]}"}
            end
        else
            formatted_response = nil
        end
    end
end