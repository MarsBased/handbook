# MarsBased Handbook

This is the MarsBased company handbook — a public collection of sections (company info, policies, onboarding) and guides (development, security, accessibility, project management).

## Deployment

The handbook is deployed via **GitBook**. GitBook uses `SUMMARY.md` as its table of contents and navigation structure. **Any page not listed in `SUMMARY.md` will not appear in the published handbook.**

## Critical rule: keep SUMMARY.md and README.md in sync

Both `SUMMARY.md` and `README.md` contain the handbook's table of contents. **Both files must be updated** when creating, renaming, moving, or deleting any `.md` file:

1. **New page** — Add an entry to both `SUMMARY.md` and `README.md` under the correct section (`Sections`, `Our guides`, `Our development guides`, `Our accessibility guides`). Follow the existing numbered-list format: `1. [Title](/path/to/file.md)`.
2. **Renamed/moved page** — Update the path in both files to match.
3. **Deleted page** — Remove its entry from both files.

Forgetting to update `SUMMARY.md` means the page won't show up on the published site. Forgetting to update `README.md` means the landing page will be out of date.

## Writing conventions

- All content is Markdown.
- Use relative paths with a leading slash for internal links (e.g. `/sections/firstday.md`).
- File and folder names use lowercase with hyphens. Avoid spaces in filenames (existing exception: `policy-digital disconnection.md`).
- Keep language clear and concise — the audience includes new hires, external visitors, and potential candidates.
