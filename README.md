# Setup Guides

Useful guidebook in Markdown format, published as a static site with MkDocs + Material theme.

- **Docs site:** https://lokeshnanda.github.io/setup-guides/
- **Source docs:** Markdown files under the `docs/` directory

## How the site is built

- The site is configured via `mkdocs.yml` at the repository root.
- GitHub Actions builds and deploys the site to GitHub Pages using `.github/workflows/pages.yml` (modeled after the workflow in [`data-engineering-learnings`](https://github.com/LokeshNanda/data-engineering-learnings/blob/main/.github/workflows/pages.yml)).
- On every push to `main`, the workflow:
  - Installs MkDocs and the Material theme
  - Builds the static site from `docs/`
  - Publishes it to GitHub Pages

## Adding new guides

1. Add a new `.md` file under `docs/` in the appropriate subfolder (for example, `docs/UTILS/`).
2. Push to `main` – GitHub Actions will:
   - Regenerate `mkdocs.yml` from `mkdocs.base.yml` and the `docs/` tree
   - Build and redeploy the site automatically

> **Note**
> The previous `scripts/update_readme.sh` flow that regenerated `README.md` is no longer required for publishing docs. You can keep using it locally if you still want an auto-generated contents section, but GitHub Pages is now driven entirely by MkDocs, a generated `mkdocs.yml`, and the CI workflow.

