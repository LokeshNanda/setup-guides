# Setup Guides

Useful guidebook in Markdown format, published as a static site

- **Docs site:** https://lokeshnanda.github.io/setup-guides/
- **Source docs:** Markdown files under the `docs/` directory

## Adding new guides

1. Add a new `.md` file under `docs/` in the appropriate subfolder (for example, `docs/DeviceSetups/`).
2. Push to `main` – GitHub Actions will:
   - Regenerate `mkdocs.yml` from `mkdocs.base.yml` and the `docs/` tree
   - Build and redeploy the site automatically

