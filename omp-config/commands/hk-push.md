---
description: "Safe commit + push: check .gitignore for secrets, stage, commit, push to GitHub"
---

Check .gitignore for these patterns before proceeding:
.env
.env.*
.mise.local.toml
*.local

If any are missing, add them. If any committed files contain secrets, warn me and ask what to do.

Then stage all changed files, generate a descriptive commit message covering what changed and why, commit, and push to origin.
