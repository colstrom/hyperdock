require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Project < Core
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

      Contract None => ArrayOf[Hash]
      def service_links
        @service_links ||= services.map do |service|
          { name: service, href: "/project/#{project}/service/#{service}" }
        end
      end

      Contract None => Hash
      def named_links
        @named_links ||= service_links.map do |service|
          { "service:#{service[:name]}" => service }
        end.reduce(&:merge)
      end

      def links
        @links ||= {
          services: service_links
        }.merge(named_links)
      end

      def attributes
        { names: services }
      end
    end
  end
end
