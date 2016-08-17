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

      Contract None => ArrayOf[HashOf[RespondTo[:to_s], String]]
      def networks
        @networks ||= (container.info.dig('NetworkSettings', 'Networks') || {})
                      .values
                      .map { |network| network['NetworkID'] }
                      .compact
                      .map { |network| { href: "/network/#{network}" } }
      end

      def volumes
        @volumes ||= container
                     .info
                     .fetch('Mounts') { [] }
                     .map { |volume| { href: "/volume/#{volume.fetch('Name')}" } }
      end

      def links
        @links ||= {
          networks: networks,
          volumes: volumes,
          ports: { href: "/#{request.disp_path}/ports" }
        }
      end

      def attributes
        { info: container.info }
      end
    end
  end
end
