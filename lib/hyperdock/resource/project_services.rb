require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class ProjectServices < Core
      Contract None => String
      def project
        @project ||= request.path_info[:project]
      end

      Contract None => ArrayOf[::Docker::Container]
      def containers
        @containers ||= ::Docker::Container.all.select do |container|
          container.info.dig('Labels', 'com.docker.compose.project') == project
        end
      end

      Contract None => Bool
      def resource_exists?
        !containers.empty?
      end

      Contract None => ArrayOf[String]
      def services
        @services ||= containers.map do |container|
          container.info.dig('Labels', 'com.docker.compose.service')
        end.uniq
      end

      Contract None => HashOf[RespondTo[:to_s], Hash]
      def links
        @links ||= services.map do |service|
          {
            "service:#{service}" => {
              href: "/project/#{project}/service/#{service}"
            }
          }
        end.reduce(&:merge)
      end

      def attributes
        { services: services }
      end
    end
  end
end
