<template>
  <BaseTitleCard title="いいねしたユーザー">
    <ArticleLikerListItem
      v-for="(liker, i) in likers"
      :key="liker.id"
      :liker="liker"
      :index="i"
    />
    <v-card-title v-if="likers != null && likers.length === 0" class="ml-1">ユーザーはいません。</v-card-title>
  </BaseTitleCard>
</template>

<script>
import Application from '~/plugins/application.js'
import BaseTitleCard from '~/components/molecules/cards/BaseTitleCard.vue'
import ArticleLikerListItem from '~/components/organisms/items/ArticleLikerListItem.vue'

export default {
  name: 'ArticleLikerListCard',

  components: {
    BaseTitleCard,
    ArticleLikerListItem
  },

  mixins: [Application],

  data () {
    return {
      likers: null
    }
  },

  async created () {
    await this.$axios.get(this.$config.apiBaseURL + this.$config.articleDetailUrl.replace('_id', this.$route.params.id))
      .then((response) => {
        if (response.data == null) {
          this.$toasted.error(this.$t('system.error'))
          return this.$router.push({ path: '/home' })
        }
        this.likers = response.data.article.likers
      },
      (error) => {
        if (error.response == null) {
          this.$toasted.error(this.$t('network.failure'))
          return this.$router.push({ path: '/home' })
        } else if (error.response.data == null && error.response.status !== 404) {
          this.$toasted.error(this.$t('network.error'))
          return this.$router.push({ path: '/home' })
        } else {
          this.$toasted.error(error.response.data.alert)
          this.$toasted.success(error.response.data.notice)
        }
      })

    this.processing = false
  }
}
</script>
