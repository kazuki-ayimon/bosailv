<template>
  <v-card outlined tile>
    <TheProcessing v-if="processing" />
    <v-img :src="article.thumbnail_url.xxlarge" max-height="256" />
    <v-col>
      <v-card-subtitle>
        <span>
          掲載日：{{ $dateFormat(article.created_at, 'ja') }}
        </span>
        <span class="ml-2">
          更新日：{{ $dateFormat(article.updated_at, 'ja') }}
        </span><br>
        <span class="mt-1">
          <v-icon small>mdi-pencil</v-icon>
          <v-avatar size="20" class="mr-1">
            <v-img :src="article.user.image_url.small" />
          </v-avatar>
          <NuxtLink :to="{ name: 'users-username___ja', params: { username: article.user.username }}" class="text-decoration-none">{{ article.user.name }}</NuxtLink>
        </span>
      </v-card-subtitle>
    </v-col>
    <v-col cols="12">
      <v-card-title class="font-weight-bold">
        {{ article.title }}
      </v-card-title>

      <div class="text-right">
        <FavoriteBtnGroup v-if="$auth.loggedIn" class="mr-3 mt-2" :article="article" :likers="likers" :disabled="canAction" />
        <v-menu v-if="canAction || ($auth.loggedIn && $auth.user.admin === true)" bottom right>
          <template #activator="{ on, attrs }">
            <v-btn
              icon
              outlined
              v-bind="attrs"
              v-on="on"
            >
              <v-icon>mdi-pencil</v-icon>
            </v-btn>
          </template>

          <v-list>
            <v-list-item :to="`/articles/${$route.params.id}/edit`">
              <v-list-item-title>編集する</v-list-item-title>
            </v-list-item>

            <v-list-item @click="onArticleDelete(article.id)">
              <v-list-item-title>削除する</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </div>
      <v-divider class="my-5" />
      <ReadOnlyEditor v-if="article.content" class="mx-2 my-2" :content="article.content" />
    </v-col>

    <v-divider class="my-5" />
    <div class="text-center mb-5">
      <TwitterShareBtn :text="shareText" :url="shareUrl" :hashtag="hashtag">
        <span class="ml-2">Twitterに投稿する</span>
      </TwitterShareBtn>
    </div>
  </v-card>
</template>

<script>
import FavoriteBtnGroup from '~/components/organisms/btnGroup/FavoriteBtnGroup.vue'
import TwitterShareBtn from '~/components/molecules/btns/TwitterShareBtn.vue'
import ReadOnlyEditor from '~/components/organisms/editor/ReadOnlyEditor.vue'
import Application from '~/plugins/application.js'

export default {
  name: 'ArticleShowDetailCard',

  components: {
    FavoriteBtnGroup,
    TwitterShareBtn,
    ReadOnlyEditor
  },

  mixins: [Application],

  props: {
    article: {
      type: Object,
      default: null
    },
    user: {
      type: Object,
      default: null
    },
    likers: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      menu: false
    }
  },
  computed: {
    authUsername () {
      return this.$auth.user.username
    },
    canAction () {
      return this.$auth.loggedIn
        ? this.currentUsername === this.authUsername
        : false
    },
    currentUsername () {
      return this.user && this.user.username
    },
    shareText () {
      return 'BosaiLvのこの記事役に立つよ！'
    },
    shareUrl () {
      return this.$config.frontBaseURL + '/articles/' + this.article.id // Tips: window.location.hrefではeditで支障をきたすため
    },
    hashtag () {
      return '防災,BosaiLv'
    }
  },
  created () {
    this.processing = false
  },
  methods: {
    async onArticleDelete (articleId) {
      this.processing = true

      await this.$axios.post(this.$config.apiBaseURL + this.$config.articleDeleteUrl.replace('_id', this.$route.params.id))
        .then((response) => {
          if (response.data == null) {
            this.$toasted.error(this.$t('system.error'))
          } else {
            this.$auth.setUser(response.data.article.user)
            this.$store.commit('articles/deleteArticle', articleId, { root: true })
            this.$toasted.error(response.data.alert)
            this.$toasted.success(response.data.notice)
            return this.$router.push({ path: '/articles' })
          }
        },
        (error) => {
          if (error.response == null) {
            this.$toasted.error(this.$t('network.failure'))
          } else if (error.response.data == null) {
            this.$toasted.error(this.$t('network.error'))
          } else {
            this.$toasted.error(error.response.data.alert)
            this.$toasted.success(error.response.data.notice)
          }
        })

      this.processing = false
    }
  }
}
</script>

// <style lang="scss" scoped>
// .img {
//   width: 100px !important;
// }
// </style>
