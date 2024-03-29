<template>
  <v-row justify="center">
    <v-col cols="12">
      <ValidationObserver v-slot="{ invalid }" ref="observer">
        <BaseTitleCard id="hazard_map_search" title="ハザードマップ検索">
          <v-row class="pa-5">
            <v-col cols="12">
              <PrefecturesSelect
                v-model="selectPrefecture"
                class="mt-5"
                rules="required"
                @change="onGetCities"
              />
            </v-col>
            <v-col cols="12">
              <CitiesSelect
                v-model="selectCity"
                :cities="cities"
                rules="required"
                @change="waiting = false"
              />
            </v-col>
            <v-col cols="12">
              <div class="text-center">
                <OrangeBtn :disabled="invalid || waiting" @click="onSearchHazardMap(selectPrefecture, selectCity)">検索</OrangeBtn>
              </div>
            </v-col>
            <v-col v-if="$auth.loggedIn && $auth.user.city" cols="12">
              <div class="text-center">
                <OrangeBtn :disabled="selectPrefecture !== null" @click="onSearchHazardMap($auth.user.prefecture.id, $auth.user.city.id)">自分の市町村で検索する</OrangeBtn>
              </div>
            </v-col>
          </v-row>
        </BaseTitleCard>
      </ValidationObserver>

      <HazardMapSearchCardText v-if="hazardMap !== null" :hazard-map="hazardMap" :select-city="selectCity" />
    </v-col>
  </v-row>
</template>

<script>
import { ValidationObserver } from 'vee-validate'
import Application from '~/plugins/application.js'
import BaseTitleCard from '~/components/molecules/cards/BaseTitleCard.vue'
import PrefecturesSelect from '~/components/organisms/select/PrefecturesSelect.vue'
import CitiesSelect from '~/components/organisms/select/CitiesSelect.vue'
import HazardMapSearchCardText from '~/components/organisms/cardText/HazardMapSearchCardText.vue'
import OrangeBtn from '~/components/atoms/btns/OrangeBtn.vue'

export default {
  name: 'HazardMapSearchCard',

  components: {
    ValidationObserver,
    BaseTitleCard,
    PrefecturesSelect,
    CitiesSelect,
    HazardMapSearchCardText,
    OrangeBtn
  },

  mixins: [Application],

  data () {
    return {
      hazardMap: null,
      cities: [],
      selectPrefecture: null,
      selectCity: null,
      waiting: false
    }
  },

  created () {
    this.processing = false
    this.waiting = true
  },

  methods: {
    async onSearchHazardMap (prefectureId, cityId) {
      this.processing = true

      this.hazardMap = null

      this.selectPrefecture = prefectureId
      this.selectCity = cityId

      await this.$axios.get(this.$config.apiBaseURL + this.$config.hazardMapUrl, {
        params: { prefecture_id: prefectureId, city_id: cityId }
      })
        .then((response) => {
          if (response.data == null || response.data.hazard_map == null) {
            this.$toasted.error(this.$t('system.error'))
            return this.$router.push({ path: '/home' })
          } else {
            this.hazardMap = response.data.hazard_map
            this.waiting = true
          }
        },
        (error) => {
          this.$toasted.error(this.$t(error.response == null ? 'network.failure' : 'network.error'))
          return this.$router.push({ path: '/home' })
        })

      this.processing = false
    },

    async onGetCities () {
      await this.$axios.get(this.$config.apiBaseURL + this.$config.setCitiesUrl.replace('_id', this.selectPrefecture))
        .then((response) => {
          if (response.data == null) {
            this.$toasted.error(this.$t('system.error'))
            return this.$router.push({ path: '/home' })
          } else {
            this.cities = response.data
            this.waiting = true
          }
        },
        (error) => {
          if (error.response == null) {
            this.$toasted.error(this.$t('network.failure'))
            return this.$router.push({ path: '/home' })
          } else if (error.response.data == null && error.response.status !== 404) {
            this.$toasted.error(this.$t('network.error'))
            return this.$router.push({ path: '/home' })
          } else {
            if (error.response.data != null) {
              this.$toasted.error(error.response.data.alert)
              this.$toasted.success(error.response.data.notice)
              this.waiting = true
            }
            return this.$nuxt.error({ statusCode: error.response.status })
          }
        })
    }
  }
}
</script>
