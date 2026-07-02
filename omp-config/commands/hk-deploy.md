---
description: "Deploy to Vercel: check auth, link project, build, deploy, share URL"
---

Let's deploy $1 to Vercel.

1. Check if logged in: `npx vercel whoami`
2. If not, tell me to run `npx vercel login` (or check VERCEL_TOKEN in env)
3. Link project: `npx vercel link --repo` or `npx vercel link` (ask me which)
4. Add `.vercel` to .gitignore (check first)
5. Deploy: `npx vercel deploy`
6. Check the preview URL works
7. If yes, deploy production: `npx vercel --prod`
8. Share the final URL with me
