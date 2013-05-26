require 'rails'

module JSON
  class Patch
    # This class registers our gem with Rails.
    class Railtie < ::Rails::Railtie
      # When the application loads, this will cause Rails to know
      # how to serve up the proper type.
      initializer 'hana' do
        Mime::Type.register 'application/json-patch+json', :hana
      end
    end
  end
end
