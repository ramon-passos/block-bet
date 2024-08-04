// https://v3.nuxtjs.org/docs/directory-structure/nuxt.config
export default defineNuxtConfig({
  modules: [
    '@vueuse/nuxt',
    '@nuxtjs/tailwindcss',
    '@instadapp/vue-web3-nuxt'
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
  }
});