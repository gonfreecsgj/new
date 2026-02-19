/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#00D4FF',
        secondary: '#7B2D8E',
        accent: '#FF006E',
        success: '#00F5D4',
        background: '#0A0A0F',
        surface: '#12121A',
        card: '#1A1A24',
      },
      fontFamily: {
        sans: ['Cairo', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
