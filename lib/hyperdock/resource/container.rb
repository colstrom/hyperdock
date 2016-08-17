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

      def links
        @links ||= {
          networks: { href: "/#{request.disp_path}/networks" },
          ports: { href: "/#{request.disp_path}/ports" }
        }
      end

      def attributes
        { info: container.info }
      end
    end
  end
end
