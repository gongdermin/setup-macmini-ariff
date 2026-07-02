# Hackathon Guardrails

These rules always apply:

## Secrets
- Never commit .env, .env.*, .mise.local.toml, *.local files.
- Before any git push, verify .gitignore covers these patterns.
- If you detect API keys in a file, ask before including them in any commit.

## Runtime management
- Use mise for all language runtimes. Never brew install node/python/bun/go/ruby.
- Pin versions with mise.toml per project.

## Scope
- If a feature request would take more than 30 minutes, suggest a simpler alternative and confirm before proceeding.
- At any point, ask "what's the smallest thing I can build right now that works?"
