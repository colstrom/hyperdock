require_relative 'container'

module HyperDock
  module Resource
    class ContainerNetworks < Container
      Contract None => ArrayOf[String]
      def networks
        @networks ||= (container.info.dig('NetworkSettings', 'Networks') || {} ).values.map do |network|
          network['NetworkID']
        end.compact
      end

      def links
        @links ||= {
          networks: networks.map { |network| { "network:#{network}" => "/network/#{network}" } }.reduce(&:merge)
        }
      end

      def attributes
        { networks: networks }
      end
    end
  end
end
