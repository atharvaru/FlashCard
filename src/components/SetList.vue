<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

// Define the interface for a Set
interface Set {
  id: string
  name: string
  description: string
  created_at: string
}

// Reactive references to store sets, error messages, selected set ID, and flashcards
const sets = ref<Set[]>([])
const error = ref('')
const selectedSetId = ref<string | null>(null)
const flashcards = ref([])

// Function to load sets from the database
const loadSets = async () => {
  try {
    // Fetch sets from the 'sets' table and order them by creation date
    const { data, error: err } = await supabase
      .from('sets')
      .select('*')
      .order('created_at', { ascending: false })

    // If there's an error
    if (err) throw err

    // Assign the fetched data to the sets reference
    sets.value = data
  } catch (err: any) {
    // If an error occurs, set the error message
    error.value = err.message
  }
}

// Function to select a set and load its flashcards
const selectSet = async (setId: string) => {
  selectedSetId.value = setId
  try {
    const { data, error: err } = await supabase
      .from('flashcards')
      .select('*')
      .eq('set_id', setId)
      .order('created_at', { ascending: false })

    if (err) throw err
    flashcards.value = data
  } catch (err: any) {
    error.value = err.message
  }
}

</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <h2 class="text-2xl font-bold mb-6">My Flashcard Sets</h2>

    <div v-if="error" class="text-red-600 mb-4">{{ error }}</div>

    <div class="grid grid-cols-1 gap-4">
      <div
        v-for="set in sets"
        :key="set.id"
        class="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow cursor-pointer"
        @click="selectSet(set.id)"
      >
        <h3 class="text-xl font-semibold mb-2">{{ set.name }}</h3>
        <p class="text-gray-600 mb-4">{{ set.description }}</p>
        <div class="text-sm text-gray-500">
          Created: {{ new Date(set.created_at).toLocaleDateString() }}
        </div>
      </div>
    </div>

    <div v-if="sets.length === 0" class="text-center text-gray-500 mt-8">
      No sets yet. Create your first one!
    </div>

    <!-- Selected Set's Flashcards -->
    <div v-if="selectedSetId" class="mt-8">
      <h3 class="text-xl font-bold mb-4">Flashcards in this Set</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div
          v-for="card in flashcards"
          :key="card.id"
          class="bg-white p-6 rounded-lg shadow-md"
        >
          <div class="mb-4">
            <h4 class="font-bold text-lg mb-2">Front:</h4>
            <p class="whitespace-pre-wrap">{{ card.front }}</p>
          </div>
          <div>
            <h4 class="font-bold text-lg mb-2">Back:</h4>
            <p class="whitespace-pre-wrap">{{ card.back }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>