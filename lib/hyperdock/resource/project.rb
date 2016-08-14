require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Project < Core
      Contract None => ArrayOf[String]
      def projects
        @projects ||= ::Docker::Container.all.map do |container|
          container.info.dig 'Labels', 'com.docker.compose.project'
        end
      end

      Contract None => Bool
      def resource_exists?
        projects.include? request.path_info[:project]
      end

      def links
        @links ||= {
          services: { href: "/#{request.disp_path}/services" }
        }
      end
    end
  end
end
