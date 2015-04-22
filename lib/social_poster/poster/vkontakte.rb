require 'vkontakte_api'

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
    end

  end
end
