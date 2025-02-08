<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from './lib/supabase'
import AuthForm from './components/AuthForm.vue'
import FlashcardForm from './components/FlashcardForm.vue'
import FlashcardList from './components/FlashcardList.vue'
import SetForm from './components/SetForm.vue'
import SetList from './components/SetList.vue'

const session = ref(null)
const activeTab = ref('sets') // 'sets' or 'cards'

onMounted(() => {
  supabase.auth.getSession().then(({ data: { session: currentSession } }) => {
    session.value = currentSession
  })

  supabase.auth.onAuthStateChange((_event, currentSession) => {
    session.value = currentSession
  })
})

const handleSignOut = async () => {
  await supabase.auth.signOut()
}
</script>

<template>
  <div class="min-h-screen bg-gray-100">
    <template v-if="session">
      <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between h-16">
            <div class="flex items-center space-x-8">
              <div class="flex-shrink-0 flex items-center">
                <h1 class="text-xl font-bold text-gray-900">Flashcards App</h1>
              </div>
              <div class="flex space-x-4">
                <button
                  @click="activeTab = 'sets'"
                  :class="[
                    'px-3 py-2 rounded-md text-sm font-medium',
                    activeTab === 'sets'
                      ? 'bg-gray-900 text-white'
                      : 'text-gray-700 hover:bg-gray-100'
                  ]"
                >
                  Sets
                </button>
                <button
                  @click="activeTab = 'cards'"
                  :class="[
                    'px-3 py-2 rounded-md text-sm font-medium',
                    activeTab === 'cards'
                      ? 'bg-gray-900 text-white'
                      : 'text-gray-700 hover:bg-gray-100'
                  ]"
                >
                  All Cards
                </button>
              </div>
            </div>
            <div class="flex items-center">
              <button
                @click="handleSignOut"
                class="ml-4 px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div class="px-4 py-6 sm:px-0">
          <template v-if="activeTab === 'sets'">
            <SetForm />
            <div class="mt-8">
              <SetList />
            </div>
          </template>
          <template v-else>
            <FlashcardForm />
            <div class="mt-8">
              <FlashcardList />
            </div>
          </template>
        </div>
      </main>
    </template>

    <AuthForm v-else />
  </div>
</template>

<style>
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}
</style>