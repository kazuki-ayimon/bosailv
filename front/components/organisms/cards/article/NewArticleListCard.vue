<template>
  <div v-if="articles != null">
    <TheProcessing v-if="processing" />
    <BaseTitleCard title="新着一覧">
      <v-card-title v-if="articles != null && articles.length === 0" class="ml-1">記事はありません。</v-card-title>
      <div v-for="article in articles" :key="article.id">
        <ArticleListCardText
          :article="article"
        />
      </div>

      <ThePagination
        class="my-3"
        :info="info"
        @pagination="onPagination"
      />
    </BaseTitleCard>
  </div>
</template>

<script>
import Application from '~/plugins/application.js'
import BaseTitleCard from '~/components/molecules/cards/BaseTitleCard.vue'
import ArticleListCardText from '~/components/organisms/cardText/ArticleListCardText.vue'
import ThePagination from '~/components/organisms/pagination/ThePagination.vue'

export default {
  name: 'NewArticleListCard',

  components: {
    BaseTitleCard,
    ArticleListCardText,
    ThePagination
  },

  mixins: [Application],

  data () {
    return {
      page: 1,
      info: null,
      articles: null
    }
  },
  async created () {
    await this.onPagination(this.page)

    this.processing = false
  },

  methods: {
    async onPagination (page) {
      this.processing = true

      await this.$axios.get(this.$config.apiBaseURL + this.$config.articlesUrl, {
        params: { page }
      })
        .then((response) => {
          if (response.data == null || response.data.article == null) {
            this.$toasted.error(this.$t('system.error'))
            if (this.info == null) {
              return this.$router.push({ path: '/home' })
            }
            this.page = this.info.current_page
          } else {
            this.info = response.data.article
            this.articles = response.data.articles
          }
        },
        (error) => {
          this.$toasted.error(this.$t(error.response == null ? 'network.failure' : 'network.error'))
          if (this.info == null) {
            return this.$router.push({ path: '/home' })
          }
          this.page = this.info.current_page
        })

      this.processing = false
    }
  }
}
</script>
