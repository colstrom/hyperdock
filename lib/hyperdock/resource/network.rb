require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Network < Core
      Contract None => Maybe[::Docker::Network]
      def network
        @network ||= ::Docker::Network.get request.path_info[:network]
      end

      Contract None => Bool
      def resource_exists?
        !network.nil?
      rescue ::Docker::Error::NotFoundError
        false
      end

      Contract None => ArrayOf[HashOf[RespondTo[:to_s], String]]
      def containers
        @containers ||= network
                        .info
                        .fetch('Containers') { {} }
                        .keys
                        .map { |container| { href: "/container/#{container}" } }
      end

      def links
        @links ||= {
          containers: containers
        }
      end

      def attributes
        network.info
      end
    end
  end
end
