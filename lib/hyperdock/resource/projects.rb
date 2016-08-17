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

      Contract None => ArrayOf[Hash]
      def project_links
        @project_links ||= projects.map do |project|
          { name: project, href: "/project/#{project}" }
        end
      end

      Contract None => Hash
      def named_links
        @named_links ||= project_links.map do |project|
          { "project:#{project[:name]}" => project }
        end.reduce(&:merge)
      end

      def links
        @links ||= {
          projects: project_links
        }.merge(named_links)
      end

      def attributes
        { names: projects }
      end
    end
  end
end
