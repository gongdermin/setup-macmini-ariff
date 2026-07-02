---
description: "Scaffold a new project: ask what to build, pick stack, init git, drop .gitignore + AGENTS.md + theme.css + mise.toml"
---

I'm starting a hackathon project called "$1".

Ask me these questions one at a time:
1. What do you want to build? (one sentence)
2. Who's it for?
3. JS/TS or Python? (default: JS on Bun + Vite)

Then do:
1. Create project directory
2. Pick the simplest tech stack that fits
3. Run `git init`, create .gitignore (cover .env, .env.*, .mise.local.toml, *.local, node_modules, .vercel, .next, dist, __pycache__)
4. Create AGENTS.md with project description, stack, palette (BB Pastel default), and a note about terminal colors
5. Create theme.css with both BB Pastel and Nord CSS vars (light + dark)
6. Create mise.toml pinning the runtime
7. Create a "Hello World" page that uses the theme
8. Run initial `git add . && git commit -m "🎉 initial scaffold"`
9. Open the project in Zed
