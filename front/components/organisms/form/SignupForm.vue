<template>
  <ValidationObserver v-slot="{ invalid }" ref="observer">
    <TheProcessing v-if="processing" />
    <v-form autocomplete="on">
      <BaseTextField
        v-model="name"
        name="name"
        label="氏名"
        rules="required|max:10"
      />

      <EmailTextField
        v-model="email"
      />

      <PasswordConfirmationTextField
        v-model="password"
        :password-confirmation.sync="passwordConfirmation"
      />

      <div class="text-center">
        <OrangeBtn
          id="sign_up_btn"
          :disabled="invalid || processing"
          @click="onSubmit"
        >
          新規登録
        </OrangeBtn>
      </div>
      <div class="text-center mt-4">
        <GuestSigninBtn :disabled="!invalid" />
      </div>
    </v-form>
  </ValidationObserver>
</template>

<script>
import { ValidationObserver } from 'vee-validate'
import TheProcessing from '~/components/organisms/application/TheProcessing.vue'
import BaseTextField from '~/components/molecules/textFields/BaseTextField.vue'
import EmailTextField from '~/components/organisms/textFields/EmailTextField.vue'
import PasswordConfirmationTextField from '~/components/organisms/textFields/PasswordConfirmationTextField.vue'
import OrangeBtn from '~/components/atoms/btns/OrangeBtn.vue'
import GuestSigninBtn from '~/components/organisms/btns/GuestSigninBtn.vue'

export default {
  name: 'SignupForm',

  components: {
    ValidationObserver,
    TheProcessing,
    BaseTextField,
    EmailTextField,
    PasswordConfirmationTextField,
    OrangeBtn,
    GuestSigninBtn
  },

  props: {
    processing: {
      type: Boolean,
      default: false
    },
    errors: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      name: '',
      email: '',
      password: '',
      passwordConfirmation: ''
    }
  },
  methods: {
    onSubmit () {
      const userInfo = {
        name: this.name,
        email: this.email,
        password: this.password,
        password_confirmation: this.passwordConfirmation
      }
      this.$emit('sign-up', userInfo)
    }
  }
}
</script>
