// @ts-check
// Docs-only Docusaurus site for More than Music with MIDI, the standing resource that grew out of the
// Processing Community Day 2026 workshop. Built by `npm run build` into build/; ../deploy-preview.sh lays
// the repo's demo folders beside it and deploys the preview Worker.

import {themes as prismThemes} from 'prism-react-renderer';

// Plausible, only on the real domain. Previews, localhost and the old workshop host send nothing.
const plausible = `
if (location.hostname === "morethanmusic.dev") {
  var s = document.createElement("script"); s.async = true; s.src = "https://plausible.io/js/pa-yF5gwkfgkdgCFrQDVmbLu.js"; document.head.appendChild(s);
  window.plausible = window.plausible || function () { (plausible.q = plausible.q || []).push(arguments) };
  plausible.init = plausible.init || function (i) { plausible.o = i || {} }; plausible.init();
}
`;

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'More than Music with MIDI',
  tagline: 'Plug in, see your messages in the Explorer within two minutes, and have a sketch reacting within ten.',
  favicon: 'img/favicon.ico',
  url: 'https://morethanmusic.dev',
  baseUrl: '/',
  // .repo-links is symlinks to the repo's demo and sketch folders (link-repo.mjs) so /starters/p5/... works in dev
  staticDirectories: ['static', '.repo-links'],
  trailingSlash: true,
  onBrokenLinks: 'throw',
  onBrokenAnchors: 'throw',
  markdown: {
    hooks: {onBrokenMarkdownLinks: 'throw'},
  },
  i18n: {defaultLocale: 'en', locales: ['en']},
  headTags: [{tagName: 'script', attributes: {}, innerHTML: plausible}],
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          showLastUpdateTime: false,
        },
        blog: false,
        theme: {customCss: './src/css/custom.css'},
      }),
    ],
  ],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {defaultMode: 'dark', disableSwitch: false, respectPrefersColorScheme: false},
      navbar: {
        title: 'More than Music with MIDI',
        items: [
          {to: '/', label: 'Start here', position: 'left'},
          {href: 'pathname:///explorer/web/', label: 'Explorer', position: 'left'},
          {to: '/devices/', label: 'Devices', position: 'left'},
          {to: '/helpers/', label: 'Helpers', position: 'left'},
          {to: '/talks/', label: 'Talks', position: 'left'},
          {href: 'https://github.com/georgemandis/morethanmusic.dev', label: 'GitHub', position: 'right'},
        ],
      },
      footer: {
        style: 'dark',
        links: [],
        copyright: 'More than Music with MIDI · <a href="https://george.mand.is">George Mandis</a>',
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['java', 'python', 'bash'],
      },
      docs: {sidebar: {hideable: false}},
      tableOfContents: {minHeadingLevel: 2, maxHeadingLevel: 3},
    }),
};

export default config;
