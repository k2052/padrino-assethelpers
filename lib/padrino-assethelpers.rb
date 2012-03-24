require 'padrino-core'
require 'padrino-helpers'

FileSet.glob_require('padrino-assethelpers/**/*.rb', __FILE__)         

module Padrino
  module AssetHelpers
    class << self   
      def registered(app)   
        app.helpers Helpers
      end
    end
  end
end