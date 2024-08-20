// https://v3.nuxtjs.org/docs/directory-structure/nuxt.config
export default defineNuxtConfig({
  modules: [
    '@vueuse/nuxt',
    '@nuxtjs/tailwindcss',
    '@instadapp/vue-web3-nuxt',
    '@nuxtjs/google-fonts',
  ],

  web3: {
    autoImport: false,
  },
  app: {
    head: {
      titleTemplate: '%s - BlockBet',
      link: [
        { rel: 'icon', type: 'image/png', href: '/logo.png' }
      ]
    },
  },
  css: [
    '~/assets/css/main.css',
  ],
  googleFonts: {
    families: {
      Gabarito: [400, 500, 600, 700, 800, 900],
      Lexend: [500],
      'Bebas Neue': [400],
    },
    display: 'swap',
  },
});