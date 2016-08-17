require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Volume < Core
      Contract None => Maybe[::Docker::Volume]
      def volume
        @volume ||= ::Docker::Volume.get request.path_info[:volume]
      end

      Contract None => Bool
      def resource_exists?
        !volume.nil?
      rescue ::Docker::Error::NotFoundError
        false
      end

      def attributes
        volume.info
      end
    end
  end
end
