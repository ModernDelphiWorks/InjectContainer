import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Documentation portal',
    },
    {
      type: 'category',
      label: 'Projects',
      items: [{ type: 'link', label: 'InjectContainer', href: '/injectcontainer/' }],
    },
  ],
  injectcontainerSidebar: [
    {
      type: 'category',
      label: 'InjectContainer',
      link: { type: 'doc', id: 'injectcontainer/index' },
      items: [
        'injectcontainer/introduction',
        {
          type: 'category',
          label: 'Getting Started',
          items: [
            'injectcontainer/getting-started/installation',
            'injectcontainer/getting-started/quickstart',
          ],
        },
        {
          type: 'category',
          label: 'Guides',
          items: [
            'injectcontainer/guides/singleton',
            'injectcontainer/guides/factory',
            'injectcontainer/guides/lazy-load',
            'injectcontainer/guides/interface-binding',
            'injectcontainer/guides/resolving-dependencies',
            'injectcontainer/guides/events-and-logging',
            'injectcontainer/guides/child-injectors',
          ],
        },
        {
          type: 'category',
          label: 'Architecture',
          items: [
            'injectcontainer/architecture/overview',
            'injectcontainer/architecture/rtti-cache',
            'injectcontainer/architecture/thread-safety',
            'injectcontainer/architecture/circular-dependency',
          ],
        },
        {
          type: 'category',
          label: 'Reference',
          items: [
            'injectcontainer/reference/api',
            'injectcontainer/reference/configuration',
          ],
        },
        {
          type: 'category',
          label: 'Troubleshooting',
          items: ['injectcontainer/troubleshooting/common-errors'],
        },
      ],
    },
  ],
};

export default sidebars;
