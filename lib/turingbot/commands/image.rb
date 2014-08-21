module Turingbot
  module Commands
    class Image < Command
      match /(image|img)( me)?/i, :image
      match /animate( me)?/i, :animate
      match /(?:mo?u)?sta(?:s|c)he?(?: me)?/i, :mustache

      def run
        case kind
        when :image
          image { |url| say url }
        when :animate
          image("animated") { |url| say url }
        when :mustache
          mustachify = "http://mustachify.me/?src="
          
          image("face") { |url| say "#{mustachify}#{url}" }
        end
      end

      def image(type=nil)
        conn = Faraday.new(:url => 'http://ajax.googleapis.com') do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end

        response = conn.get do |req|
          req.url '/ajax/services/search/images'
          req.params['v'] = 1.0
          req.params['rsz'] = 8
          req.params['q'] = argument
          req.params['safe'] = 'active'
          req.params['imgtype'] = type if type
        end

        body = JSON.load(response.body)

        images = body['responseData']['results']

        images.reject! do |img|
          img['width'].to_i > 1024
        end

        image = images.shuffle.first

        yield image["unescapedUrl"]
      end
    end
  end
end
