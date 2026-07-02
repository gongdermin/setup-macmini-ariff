/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['selector', '[data-theme="dark"]'],
  content: ['./**/*.{html,js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        base: 'var(--bg-base)',
        surface: 'var(--bg-surface)',
        primary: 'var(--primary)',
        muted: 'var(--muted)',
        gold: 'var(--gold)',
        coral: 'var(--coral)',
        accent: 'var(--accent)',
        border: 'var(--border)',
      },
      borderRadius: {
        DEFAULT: 'var(--radius)',
      },
    },
  },
  plugins: [],
}
