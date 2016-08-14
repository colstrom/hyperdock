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
        end.map(&:id)
      end

      def links
        @links ||= {
          'containers' => containers.map do |container|
            { href: "/container/#{container}" }
          end
        }
      end
    end
  end
end
