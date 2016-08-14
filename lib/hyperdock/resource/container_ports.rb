require_relative 'container'

module HyperDock
  module Resource
    class ContainerPorts < Container
      Contract None => ArrayOf[Hash]
      def ports
        @ports ||= container.info.fetch('Ports') { [] }
      end

      def public_port
        @public_port ||= ports.group_by { |port| port['PublicPort'] }
      end

      def private_port
        @private_port ||= ports.group_by { |port| port['PrivatePort'] }
      end

      def ip
        @ip ||= ports.group_by { |port| port['IP'] }
      end

      def type
        @type ||= ports.group_by { |port| port['Type'] }
      end

      def tcp
        @tcp ||= ports.select { |port| port['Type'] == 'tcp' }
      end

      def udp
        @udp ||= ports.select { |port| port['Type'] == 'udp' }
      end

      def attributes
        {
          all: ports,
          PublicPort: public_port,
          PrivatePort: private_port,
          IP: ip,
          Type: type,
          tcp: tcp,
          udp: udp
        }
      end
    end
  end
end
