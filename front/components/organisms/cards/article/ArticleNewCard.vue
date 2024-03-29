<template>
  <v-row justify="center">
    <v-col v-if="!success" cols="12" sm="10" md="8">
      <BaseTitleCard title="記事作成" />
      <ArticleNewForm
        :processing="processing"
        @article-create="onArticleCreate"
      />
    </v-col>
    <v-col v-else cols="12" sm="10" md="8">
      <ArticleCreateSuccessCard :article="article" />
    </v-col>
  </v-row>
</template>

<script>
import Application from '~/plugins/application.js'
import BaseTitleCard from '~/components/molecules/cards/BaseTitleCard.vue'
import ArticleNewForm from '~/components/organisms/form/ArticleNewForm.vue'
import ArticleCreateSuccessCard from '~/components/organisms/cards/article/ArticleCreateSuccessCard.vue'

export default {
  name: 'ArticleNewCard',

  components: {
    BaseTitleCard,
    ArticleNewForm,
    ArticleCreateSuccessCard
  },

  mixins: [Application],

  data () {
    return {
      errors: null,
      success: false,
      article: null
    }
  },
  created () {
    this.processing = false
  },

  methods: {
    async onArticleCreate (articleInfo) {
      this.processing = true

      const params = new FormData()
      params.append('article[title]', articleInfo.title)
      params.append('article[content]', articleInfo.content)
      params.append('article[thumbnail]', articleInfo.thumbnail)
      articleInfo.selectedGenres.forEach((genre) => {
        params.append('article[genre_ids][]', genre)
      })

      await this.$axios.post(this.$config.apiBaseURL + this.$config.articleCreateUrl, params)
        .then((response) => {
          if (response.data == null) {
            this.$toasted.error(this.$t('system.error'))
          } else {
            this.$store.commit('user/setLevel', response.data.article.user.level, { root: true })
            this.$auth.setUser(response.data.article.user)
            this.$store.commit('articles/addArticles', response.data.article, { root: true })
            this.$toasted.error(response.data.alert)
            this.$toasted.success(response.data.notice)
            this.success = true
            this.article = response.data.article
          }
        },
        (error) => {
          if (error.response == null) {
            this.$toasted.error(this.$t('network.failure'))
          } else if (error.response.data == null) {
            this.$toasted.error(this.$t('network.error'))
          } else {
            this.$emit('alert', error.response.data.alert)
            this.$emit('notice', error.response.data.notice)
          }
        })

      this.processing = false
    }
  }
}
</script>
