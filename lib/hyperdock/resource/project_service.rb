require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class ProjectService < Core
      PROJECT_LABEL = 'com.docker.compose.project'.freeze
      SERVICE_LABEL = 'com.docker.compose.service'.freeze

      def project
        @project ||= request.path_info[:project]
      end

      def service
        @service ||= request.path_info[:service]
      end

      def matches_project?(container)
        container.info.dig('Labels', PROJECT_LABEL) == project
      end

      def matches_service?(container)
        container.info.dig('Labels', SERVICE_LABEL) == service
      end

      def containers
        @containers ||= ::Docker::Container.all.select do |container|
          matches_project?(container) && matches_service?(container)
        end
      end

      def container_links
        @container_links ||= containers.flat_map do |container|
          # TODO: Determine how this should be presented.
          [container.info.fetch('Names').first].map do |name|
            { name: name, href: "/container/#{container.id}" }
          end
        end
      end

      def named_links
        @named_links ||= container_links.map do |container|
          { "container:#{container[:name]}" => container }
        end.reduce(&:merge)
      end

      def links
        @links ||= {
          containers: container_links
        }.merge(named_links)
      end

      def attributes
        { name: service }
      end
    end
  end
end
