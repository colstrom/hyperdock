require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Containers < Core
      def containers
        @containers ||= ::Docker::Container.all.map(&:id)
      end

      def links
        @links ||= containers.map do |container|
          { "container:#{container}" => { href: "/container/#{container}" } }
        end.reduce(&:merge)
      end

      def attributes
        { containers: containers }
      end
    end
  end
end
