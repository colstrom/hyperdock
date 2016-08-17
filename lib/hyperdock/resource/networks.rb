require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Networks < Core
      def networks
        @networks ||= ::Docker::Network.all.map(&:id)
      end

      def links
        @links ||= networks.map do |network|
          { "network:#{network}" => { href: "/network/#{network}" } }
        end.reduce(&:merge)
      end

      def attributes
        { networks: networks }
      end
    end
  end
end
