<template>
  <OneColumnContainer>
    <TheLoading v-if="loading" />
    <TheMessage v-if="!loading" :alert="alert" :notice="notice" />

    <SignupCard v-if="!loading" @alert="alert = $event" @notice="notice = $event" />
  </OneColumnContainer>
</template>

<script>
import Application from '~/plugins/application.js'
import OneColumnContainer from '~/components/molecules/containers/OneColumnContainer.vue'
import TheLoading from '~/components/organisms/application/TheLoading.vue'
import TheMessage from '~/components/organisms/application/TheMessage.vue'
import SignupCard from '~/components/organisms/cards/SignupCard.vue'

export default {
  name: 'SignUpIndex',

  components: {
    OneColumnContainer,
    TheLoading,
    TheMessage,
    SignupCard
  },

  mixins: [Application],

  created () {
    if (this.$auth.loggedIn) {
      return this.redirectAlreadyAuth()
    }
    this.loading = false
  }
}
</script>
