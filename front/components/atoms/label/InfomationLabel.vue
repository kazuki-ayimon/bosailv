<template>
  <v-chip v-if="infomation != null && infomation.label !== 'not'" small :color="labelColor">{{ infomation.label_i18n }}</v-chip>
</template>

<script>
export default {
  name: 'InfomationLabel',

  props: {
    infomation: {
      type: Object,
      default: null
    }
  },

  computed: {
    labelColor () {
      switch (this.infomation.label) {
        case 'maintenance':
          return 'error'
        case 'hindrance':
          return 'warning'
        default:
          return 'info'
      }
    }
  }
}
</script>
