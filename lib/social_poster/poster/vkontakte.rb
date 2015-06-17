require 'vkontakte_api'
require 'open-uri'

module SocialPoster
  module Poster
    
    class Vkontakte
      include SocialPoster::Helper

      def initialize(options)
        @options = options
        @app = VkontakteApi::Client.new(config_key :access_token)
      end

      def write(text, title)
        @app.wall.post({message: text}.merge(@options))
      end
      
      def vk_album_id(group_id)
        album_title = "#{I18n.l(Time.zone.today, :format => '%B-%Y')}"
        album_id = nil
        album = @app.photos.get_albums(owner_id: group_id).select{|g| g.title == album_title}
    
        if album.one?
          album_id = album.first.aid
        else
          album_id = create_vk_album(group_id)
        end
    
        album_id
      end
    
      def create_vk_album(group_id)
        album = @app.photos.create_album(title: "#{I18n.l(Time.zone.today, :format => '%B-%Y')}", group_id: group_id, comment_privacy: 1, privacy: 1)
        album.aid
      end
    
      def upload_poster_to_vk(image_url, group_id)
        begin
          album_id = vk_album_id(@app)
          up_serv = @app.photos.get_upload_server(aid: album_id, group_id: group_id)
          upload = VkontakteApi.upload(url: up_serv.upload_url, photo: [open(image_url), mime_type(image_url)])
          photo = @app.photos.save(upload)
          photo_vk_id = "photo#{photo.first.owner_id}_#{photo.first.pid}"
        rescue VkontakteApi::Error => e
        end
      end
      
      def mime_type(path)
        case path
        when /\.jpe?g/i
          'image/jpeg'
        when /\.gif$/i
          'image/gif'
        when /\.png$/i
          'image/png'
        else
          'application/octet-stream'
        end
      end
    end

  end
end
