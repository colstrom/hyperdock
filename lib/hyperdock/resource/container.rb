require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Container < Core
      Contract None => Maybe[::Docker::Container]
      def container
        @container ||= ::Docker::Container.all.select do |container|
          container.id == request.path_info[:container]
        end.first
        #::Docker::Container.get id
      end

      Contract None => Bool
      def resource_exists?
        !container.nil?
      rescue ::Docker::Error::NotFoundError
        false
      end

      def attributes
        @attributes ||= container.info
      end

      Contract None => Hash
      def networks
        @networks ||= attributes.dig('NetworkSettings', 'Networks') || {}
      end

      Contract None => ArrayOf[Hash]
      def network_links
        @network_links ||= networks.flat_map do |name, network|
          { name: name, href: "/network/#{network['NetworkID']}" }
        end
      end

      Contract None => ArrayOf[Hash]
      def volumes
        @volumes ||= attributes.fetch('Mounts') { [] }
      end

      Contract None => ArrayOf[Hash]
      def volume_links
        @volume_links ||= volumes.map do |volume|
          { name: volume['Destination'], href: "/volume/#{volume['Name']}" }
        end
      end

      def named_links
        @named_links ||= [
          network_links
            .map { |network| { "network:#{network[:name]}" => network } },
          volume_links
            .map { |volume| { "volume:#{volume[:name]}" => volume } }
        ].flatten.reduce(&:merge)
      end

      Contract None => HashOf[RespondTo[:to_s], Or[Hash, ArrayOf[Hash]]]
      def links
        @links ||= {
          networks: network_links,
          volumes: volume_links,
          ports: { href: "/#{request.disp_path}/ports" }
        }.merge(named_links)
      end
    end
  end
end
