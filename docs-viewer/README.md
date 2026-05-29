# Markdown Preview

A local markdown documentation viewer with Notion-grade readability. Built on **VitePress**, styled with **Inter + Pretendard** for clean Latin and CJK rendering. Fully responsive for desktop and mobile, and exposes the dev server on your LAN so you can open it on your phone over the same Wi-Fi.

## Use in a new project

Run one line in the project folder where you want the viewer:

```bash
npx degit ilwonyoon/markdown-preview docs-viewer && cd docs-viewer && npm install
```

This creates a `docs-viewer/` folder with its own independent copy of the viewer.

## View documents

```bash
cd docs-viewer
npm run dev
```

- Desktop: <http://localhost:5180>
- Mobile (same Wi-Fi):
  ```bash
  npm run ip      # prints your Mac's local IP (e.g. 192.168.1.42)
  ```
  Open `http://<that-IP>:5180` on your phone. Bookmark it once and the address stays stable across sessions.

## Add documents

Drop `.md` files anywhere under `docs-viewer/docs/`. To show them in the sidebar, add an entry to the `sidebar` section in `docs-viewer/docs/.vitepress/config.ts`:

```ts
sidebar: {
  '/notes/': [
    {
      text: 'Notes',
      items: [
        { text: 'Index', link: '/notes/' },
        { text: 'New document', link: '/notes/new-doc' },  // ← add this
      ],
    },
  ],
},
```

### Link your project's existing docs folder

If your project already has a `docs/` folder, symlink it in:

```bash
cd docs-viewer/docs
ln -s ../../docs project-docs
```

It then appears at `/project-docs/...`. Register the relevant pages in the sidebar config the same way.

## Folder layout

```
docs-viewer/
├── docs/
│   ├── .vitepress/
│   │   ├── config.ts          # site meta + sidebar
│   │   └── theme/
│   │       ├── index.ts
│   │       └── custom.css     # Inter + Pretendard + black theme
│   ├── index.md               # home
│   ├── guides/
│   └── notes/
├── package.json
└── README.md
```

## Scripts

| Command           | Description                                |
| ----------------- | ------------------------------------------ |
| `npm run dev`     | dev server (LAN-exposed, port 5180)        |
| `npm run build`   | build a static site (only if you deploy)   |
| `npm run preview` | preview the built site                     |
| `npm run ip`      | print your Mac's local IP (for mobile)     |

## Design

- **Fonts**: Inter (Latin body / UI) + Pretendard Variable (Korean), with JetBrains Mono → SF Mono fallback for code
- **Theme**: monochrome — pure black as the accent (light mode) / pure white (dark mode), no blue
- **Body**: 17px on desktop, 16px on mobile, line-height 1.75–1.8 tuned for Korean readability
- **Sidebar**: 300px, pinned left; dark mode, local search, auto outline — all built in

## When the upstream design updates

Each project's viewer is an independent copy, so updates do not propagate automatically. Easiest refresh:

```bash
cd my-project
mv docs-viewer docs-viewer.old
npx degit ilwonyoon/markdown-preview docs-viewer
cp -r docs-viewer.old/docs/notes docs-viewer/docs/                       # bring your docs back
cp docs-viewer.old/docs/.vitepress/config.ts docs-viewer/docs/.vitepress/ # bring your sidebar back
cd docs-viewer && npm install
```

---

To change the design or add features for *all* future projects, edit this repo and push. `npx degit` always pulls the latest `main`.
