# Dev Tasks

Done:

- `default/bin/check-bin-executables` checks shebang files in `default/bin` and
  `desktop/bin`.
- `default/bin/check-bin-executables --fix` applies missing executable bits.
- `make check-bin-executables` and `make fix-bin-executables` wrap those
  commands.
- Pre-commit runs the executable-bit check, so CI enforces it through the
  existing pre-commit workflow.

Open:

- Decide whether local pre-commit should run `act`. This is intentionally not
  enabled yet because it is much heavier than normal pre-commit hooks and may
  require local Docker/GitHub Actions setup.
