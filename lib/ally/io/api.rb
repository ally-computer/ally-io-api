require 'ally/io'
require 'ally/io/api/version'

module Ally
  module Io
    class Api
      include Ally::Io

    
      def say(text)
        super # do not delete
        # Your code goes here...
      end
      def listen
        # daemon process listening for incoming inquiries
      end
    
    end
  end
end
