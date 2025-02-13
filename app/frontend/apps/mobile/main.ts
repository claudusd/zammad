// Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

import { createApp } from 'vue'
import '@shared/initializer/translatableMarker'
import App from '@mobile/App.vue'
import useSessionStore from '@shared/stores/session'
import '@mobile/styles/main.css'
import initializeApolloClient from '@mobile/server/apollo'
import initializeStore from '@shared/stores'
import initializeStoreSubscriptions from '@shared/initializer/storeSubscriptions'
import initializeGlobalComponents from '@shared/initializer/globalComponents'
import initializeRouter from '@mobile/router'
import useApplicationStore from '@shared/stores/application'
import useLocaleStore from '@shared/stores/locale'
import useAuthenticationStore from '@shared/stores/authentication'
import 'virtual:svg-icons-register' // eslint-disable-line import/no-unresolved
import initializeForm from '@mobile/form'
import initializeGlobalProperties from '@shared/initializer/globalProperties'

export default async function mountApp(): Promise<void> {
  const app = createApp(App)

  // TODO remove when Vue 3.3 released
  app.config.unwrapInjectedRef = true

  initializeApolloClient(app)

  initializeStore(app)
  initializeRouter(app)

  initializeGlobalComponents(app)

  initializeStoreSubscriptions()

  const session = useSessionStore()
  await session.checkSession()

  const application = useApplicationStore()

  const initalizeAfterSessionCheck: Array<Promise<unknown>> = [
    application.getConfig(),
  ]

  if (session.id) {
    useAuthenticationStore().authenticated = true
    initalizeAfterSessionCheck.push(session.getCurrentUser())
  }
  await Promise.all(initalizeAfterSessionCheck)

  const locale = useLocaleStore()

  if (!locale.localeData) {
    await locale.updateLocale()
  }

  initializeGlobalProperties(app)

  initializeForm(app)

  app.mount('#app')
}
