<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->
<script setup lang="ts">
import CommonAvatar from '@shared/components/CommonAvatar/CommonAvatar.vue'
import useSessionStore from '@shared/stores/session'
import { getInitials } from '@shared/utils/formatter'
import { storeToRefs } from 'pinia'

const { user } = storeToRefs(useSessionStore())
</script>

<template>
  <footer
    class="fixed bottom-0 z-10 flex h-14 w-full items-center bg-gray-light text-center backdrop-blur-lg"
  >
    <CommonLink
      link="/"
      class="flex flex-1 justify-center"
      exact-active-class="text-blue"
    >
      <CommonIcon name="home" size="small" />
    </CommonLink>
    <CommonLink link="/notifications" class="flex flex-1 justify-center">
      <CommonIcon name="bell" size="medium" />
    </CommonLink>
    <CommonLink link="/account" class="flex-1" exact-active-class="user-active">
      <!-- TODO use CommonUserAvatar with entity -->
      <CommonAvatar
        class="user-avatar bg-red"
        :initials="getInitials(user?.firstname, user?.lastname)"
      />
    </CommonLink>
  </footer>
</template>

<style scoped lang="scss">
.user-active {
  .user-avatar {
    @apply outline outline-2 outline-blue;
  }
}
</style>
