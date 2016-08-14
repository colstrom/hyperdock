require 'contracts'
require 'rakuna'

module HyperDock
  module Resource
    class Core < ::Rakuna::Resource::Basic
      include ::Contracts::Core
      include ::Contracts::Builtin
      include ::Rakuna::Provides::JSON

      Contract None => ArrayOf[String]
      def allowed_methods
        ['GET', 'HEAD']
      end

      Contract None => HashOf[RespondTo[:to_s], HashOf[RespondTo[:to_s], Any]]
      def _links
        { self: { href: "/#{request.disp_path}" } }
      end

      Contract None => HashOf[RespondTo[:to_s], HashOf[RespondTo[:to_s], Hash]]
      def links
        {}
      end

      Contract None => HashOf[RespondTo[:to_s], Any]
      def attributes
        {}
      end

      Contract None => RespondTo[:to_json]
      def output
        { _links: _links.merge(links) }.merge(attributes)
      end
    end
  end
end
