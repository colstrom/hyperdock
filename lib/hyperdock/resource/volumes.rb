require 'docker-api'
require_relative 'core'

module HyperDock
  module Resource
    class Volumes < Core
      def volumes
        @volumes ||= ::Docker::Volume.all.map(&:id)
      end

      def links
        @links ||= volumes.map do |volume|
          { "volume:#{volume}" => { href: "/volume/#{volume}" } }
        end.reduce(&:merge)
      end

      def attributes
        { volumes: volumes }
      end
    end
  end
end
