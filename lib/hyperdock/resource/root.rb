require_relative 'core'

module HyperDock
  module Resource
    class Root < Core
      VERSION = 1

      def attributes
        { version: VERSION }
      end

      def links
        @links ||= {
          projects: { href: '/projects' },
          project: { href: '/project/{project}', templated: true },
          'project:services' => { href: '/project/{project}/services', templated: true },
          containers: { href: '/containers' },
          container: { href: '/container/{container}', templated: true },
          'container:ports' => { href: '/container/{container}/ports', templated: true }
        }
      end
    end
  end
end
