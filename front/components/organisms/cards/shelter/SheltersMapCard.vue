<template>
  <ValidationObserver v-slot="{ invalid }" ref="observer">
    <v-row justify="center">
      <v-col cols="12">
        <BaseTitleCard id="shelter_map_search" title="避難所検索">
          <v-row class="pa-5">
            <v-col cols="12">
              <DisasterTypeSelect
                v-model="selectDisasterType"
                class="mt-2"
                @change="waiting = false"
              />
            </v-col>
            <v-col cols="12">
              <PrefecturesSelect
                v-model="selectPrefecture"
                rules="required"
                @change="onGetCities"
              />
            </v-col>
            <v-col cols="12">
              <CitiesSelect
                v-model="selectCity"
                rules="required"
                :cities="cities"
                @change="waiting = false"
              />
            </v-col>
            <v-col cols="12">
              <div class="text-center">
                <OrangeBtn :disabled="invalid || waiting" @click="onSearchShelters(page, selectPrefecture, selectCity)">検索</OrangeBtn>
              </div>
            </v-col>
            <v-col v-if="$auth.loggedIn && $auth.user.city" cols="12">
              <div class="text-center">
                <OrangeBtn :disabled="selectPrefecture !== null" @click="onSearchShelters(page, $auth.user.prefecture.id, $auth.user.city.id)">自分の市町村で検索する</OrangeBtn>
              </div>
            </v-col>
          </v-row>
        </BaseTitleCard>

        <SheltersMap
          v-if="shelters !== null"
          :shelters="shelters"
        />

        <SheltersListCard
          v-if="shelters !== null"
          :shelters="shelters"
          :info="info"
          :processing="processing"
          @pagination="onSheltersPagination"
        />
      </v-col>
    </v-row>
  </ValidationObserver>
</template>

<script>
import { ValidationObserver } from 'vee-validate'
import Application from '~/plugins/application.js'
import BaseTitleCard from '~/components/molecules/cards/BaseTitleCard.vue'
import PrefecturesSelect from '~/components/organisms/select/PrefecturesSelect.vue'
import CitiesSelect from '~/components/organisms/select/CitiesSelect.vue'
import DisasterTypeSelect from '~/components/organisms/select/DisasterTypeSelect.vue'
import SheltersMap from '~/components/organisms/maps/SheltersMap.vue'
import SheltersListCard from '~/components/organisms/cards/shelter/SheltersListCard.vue'
import OrangeBtn from '~/components/atoms/btns/OrangeBtn.vue'

export default {
  name: 'SheltersMapCard',

  components: {
    ValidationObserver,
    BaseTitleCard,
    PrefecturesSelect,
    CitiesSelect,
    DisasterTypeSelect,
    SheltersMap,
    SheltersListCard,
    OrangeBtn
  },

  mixins: [Application],

  data () {
    return {
      page: 1,
      info: null,
      shelters: null,
      cities: [],
      selectPrefecture: null,
      selectCity: null,
      selectDisasterType: null,
      waiting: false
    }
  },

  created () {
    this.processing = false
    this.waiting = true
  },

  methods: {
    async onSearchShelters (page, prefectureId, cityId) {
      this.processing = true

      this.selectPrefecture = prefectureId
      this.selectCity = cityId

      await this.$axios.get(this.$config.apiBaseURL + this.$config.sheltersUrl, {
        params: { city_id: cityId, page, disaster_type: this.selectDisasterType, prefecture_id: prefectureId }
      })
        .then((response) => {
          if (response.data == null || response.data.shelters == null) {
            this.$toasted.error(this.$t('system.error'))
            if (this.info == null) {
              return this.$router.push({ path: '/home' })
            }
            this.page = this.info.current_page
          } else {
            this.info = response.data.shelter
            this.shelters = response.data.shelters
            this.waiting = true
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
    },

    async onSheltersPagination (page) {
      this.processing = true

      await this.$axios.get(this.$config.apiBaseURL + this.$config.sheltersUrl, {
        params: { city_id: this.selectCity, page, disaster_type: this.selectDisasterType, prefecture_id: this.selectPrefecture }
      })
        .then((response) => {
          if (response.data == null || response.data.shelters == null) {
            this.$toasted.error(this.$t('system.error'))
            if (this.info == null) {
              return this.$router.push({ path: '/home' })
            }
            this.page = this.info.current_page
          } else {
            this.info = response.data.shelter
            this.shelters = response.data.shelters
            this.waiting = true
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
