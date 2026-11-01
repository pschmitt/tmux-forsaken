# Agent guidance

`tmux-forsaken` is a tmux plugin with its entry point in `forsaken.tmux` and helper scripts under `scripts/`.

## Development

- Keep plugin behavior and installation instructions in `README.md` aligned.
- Validate script syntax using each script's declared interpreter and test integration in a disposable tmux server.
- Do not run commands that kill sessions in a user's live tmux server during validation.
- Load the `shell` skill before changing shell scripts.

## CI

- Before changing GitHub Actions, inspect the current guidance in `pschmitt/ci-workflows`. Use `@main` in every `uses:` reference to a shared workflow or action.
