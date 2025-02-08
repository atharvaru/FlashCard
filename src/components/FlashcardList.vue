<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

// Define the Flashcard interface
interface Flashcard {
  id: string
  front: string
  back: string
  created_at: string
  last_reviewed: string | null
}

// Reactive reference to store flashcards
const flashcards = ref<Flashcard[]>([])
const error = ref('')

// Function to load flashcards from the database
const loadFlashcards = async () => {
  try {
    // get flashcards from the 'flashcards' table in order by creation date
    const { data, error: err } = await supabase
      .from('flashcards')
      .select('*')
      .order('created_at', { ascending: false })

    // error if the fetch fails
    if (err) throw err
    // Update the flashcards reference with the fetched data
    flashcards.value = data
  } catch (err: any) {
    // Update the error reference with the error message
    error.value = err.message
  }
}

// Load flashcards when the component is mounted
onMounted(() => {
  loadFlashcards()
})
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <h2 class="text-2xl font-bold mb-6">My Flashcards</h2>

    <div v-if="error" class="text-red-600 mb-4">{{ error }}</div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div
        v-for="card in flashcards"
        :key="card.id"
        class="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
      >
        <div class="mb-4">
          <h3 class="font-bold text-lg mb-2">Front:</h3>
          <p class="whitespace-pre-wrap">{{ card.front }}</p>
        </div>
        <div>
          <h3 class="font-bold text-lg mb-2">Back:</h3>
          <p class="whitespace-pre-wrap">{{ card.back }}</p>
        </div>
        <div class="mt-4 text-sm text-gray-500">
          Created: {{ new Date(card.created_at).toLocaleDateString() }}
        </div>
      </div>
    </div>

    <div v-if="flashcards.length === 0" class="text-center text-gray-500 mt-8">
      No flashcards yet. Create your first one!
    </div>
  </div>
</template>