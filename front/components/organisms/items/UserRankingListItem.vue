<template>
  <div>
    <BaseListItem :to="`/users/${user.username}`">
      <div v-if="[0, 1, 2].includes(index)" style="width: 50px;" class="text-center">
        <v-list-item-icon v-if="index === 0">
          <v-icon style="color: #ffc400;">
            mdi-medal-outline
          </v-icon>
        </v-list-item-icon>
        <v-list-item-icon v-if="index === 1">
          <v-icon style="color: #c9c9c9;">
            mdi-medal-outline
          </v-icon>
        </v-list-item-icon>
        <v-list-item-icon v-if="index === 2">
          <v-icon style="color: #ac6d4d;">
            mdi-medal-outline
          </v-icon>
        </v-list-item-icon>
      </div>
      <div v-else style="width: 50px;" class="text-center">
        <v-list-item-icon>
          <v-icon class="ml-1 mr-2">
            {{ index + 1 }}
          </v-icon>
        </v-list-item-icon>
      </div>
      <v-list-item-avatar>
        <v-img :src="user.image_url.mini" />
      </v-list-item-avatar>
      <v-list-item-title class="pl-2">
        {{ user.name }}
      </v-list-item-title>
      <v-list-item-title class="amber--text text--darken-4">
        {{ user.lifelong_point }}<span class="black--text px-2">pt</span>
      </v-list-item-title>
    </BaseListItem>
    <v-divider />
  </div>
</template>

<script>
import BaseListItem from '~/components/molecules/items/BaseListItem.vue'

export default {
  name: 'UserRankingListItem',

  components: {
    BaseListItem
  },

  props: {
    user: {
      type: Object,
      required: true
    },
    index: {
      type: Number,
      required: true
    }
  }
}
</script>
