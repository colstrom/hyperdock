require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Projects < Core
      Contract None => ArrayOf[Maybe[String]]
      def projects
        @projects ||= ::Docker::Container.all.map do |container|
          container.info.dig 'Labels', 'com.docker.compose.project'
        end.uniq
      end

      Contract None => HashOf[RespondTo[:to_s], Hash]
      def links
        @links ||= projects.map do |project|
          { "project:#{project}" => { href: "/project/#{project}" } }
        end.reduce(&:merge)
      end

      def attributes
        { projects: projects }
      end
    end
  end
end
