# Hackathon Day Setup 🚀

Welcome to your first hackathon! This guide is your day-of cheat sheet. Keep it open.

---

## Step 1 — Open Terminal and Run Setup

This should already be done by your parent. If not, ask for help — the script sets up
everything: Homebrew, WezTerm, Zed, Oh My Pi (OMP), and all the tools you will need.

```bash
cd ~/Desktop/setup-macmini-ariff   # or wherever the folder is
bash setup.sh
```

---

## Step 2 — Start Oh My Pi

```bash
pi
```

OMP is your AI coding assistant. You talk to it using **slash commands** (`/` commands).
When you type `/hk-start`, it will scaffold an entire project for you.

If `pi` is not found yet, run this once:

```bash
eval "$(mise activate zsh)"
```

---

## Step 3 — Set Your API Key

Ask your parent for the API key, then:

```bash
pi config set modelRoles.default opencode-go/deepseek-v4-flash
```

You only need to do this once. After that, OMP is ready to go.

---

## Slash Commands

| Command       | What it does |
|---------------|-------------|
| `/hk-start`   | Scaffold a new project (choose template) |
| `/hk-stuck`   | Debug an error — paste the error message |
| `/hk-cut`     | Trim features down to what fits the demo |
| `/hk-push`    | Safe commit + push to GitHub |
| `/hk-demo`    | Generate README + demo script for judging |
| `/hk-deploy`  | Deploy your project to Vercel |
| `/hk-data`    | Scaffold a database / data layer |
| `/hk-design`  | Generate components using BB Pastel or Nord theme |

### Pro tips for slash commands

- **Be specific.** Instead of "make a website", say "make a Next.js landing page for a
  climate app called GreenScore with a hero and a features grid".
- **Show errors.** If `/hk-stuck` does not have the error, just paste it after running
  the command.
- **Use `/hk-design` early.** Tell it "Nord theme" or "BB Pastel theme" and it will
  match your color palette.

---

## Tips for the Day

- **AGENTS.md** — Create a file called `AGENTS.md` in your project folder and write
  what you are building in plain English. OMP reads it for context.
- **.gitignore** — OMP auto-checks this. You do not need to remember it.
- **Commit early, commit often.** Use `/hk-push` for a safe commit — it writes a
  good commit message for you.
- **Stuck for more than 15 minutes?** Run `/hk-stuck` with the error. If you are
  still stuck, ask a mentor or your parent.
- **Running out of time?** `/hk-cut` will trim features to only what you can demo.
  Do this 1 hour before the deadline.
- **Ready to present?** Run `/hk-demo` to generate a README and a demo walkthrough.
  Judges love a good README.

---

## Your Color Palettes

Two color palettes are ready to use in designs:

**BB Pastel (default)** — School-inspired green tones
- Light background: `#F4F9F6`
- Surface: `#E6F0EA`
- Text: `#1E3A2F`
- Primary: `#2D6B52`
- Muted: `#4D7566`
- Gold accent: `#F7D97A`
- Coral accent: `#F0A099`

**Nord (alternative)** — Cool blue-grey tones
- Light background: `#ECEFF4`
- Surface: `#E5E9F0`
- Text: `#2E3440`
- Primary: `#4C6D8C`
- Muted: `#4C566A`
- Cyan accent: `#88C0D0`

Both pass **WCAG AA** contrast requirements — your designs will be readable.

---

## Have Fun! 🎉

You have all the tools you need. Build something cool, learn a lot, and ship it.

> "The best time to start is now. The second best time is after `/hk-stuck`."
