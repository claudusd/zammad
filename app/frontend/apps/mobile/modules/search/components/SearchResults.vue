<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
/* eslint-disable vue/no-v-html */

import { replaceTags } from '@shared/utils/formatter'
import { computed } from 'vue'
import { useSearchPlugins } from '../plugins'

interface Props {
  type: string
  data: Record<string, unknown>[]
}

const props = defineProps<Props>()

const searchPlugins = useSearchPlugins()

const plugin = computed(() => searchPlugins[props.type])
</script>

<template>
  <template v-for="item in data" :key="item.id">
    <CommonLink :link="replaceTags(plugin.link, item, true)">
      <component :is="plugin.component" :entity="item">
        <div
          class="font-normal"
          v-html="plugin.itemTitle?.(item) || item.title"
        ></div>
      </component>
    </CommonLink>
  </template>
</template>
