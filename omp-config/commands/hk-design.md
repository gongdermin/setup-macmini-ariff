---
description: "Generate UI components using project theme: pick palette, generate component code, open in browser"
---

I need a $1 component for $2.

First, read the project's AGENTS.md and theme.css to get the active palette.

Ask me if I want BB Pastel (school-inspired warm tones) or Nord (arctic clean) for this component. Default to whichever is in AGENTS.md.

Then:
1. Generate the component using Tailwind classes from the palette (--bg-base, --text, --primary, etc.)
2. If using shadcn/ui, use the pre-configured components.json
3. Use the palette's generate_image prompt prefix for any images:
   - BB Pastel: "soft sage greens, butter yellows, peach tones, clean white space"
   - Nord: "arctic blues, cool greys, snow whites"
4. Create the component file
5. If it can be previewed, open dev server and show me
6. List the color tokens used so I know what maps to what
