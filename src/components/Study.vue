<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

// interfaces for Set and Flashcard
interface Set {
  id: string
  name: string
}

interface Flashcard {
  id: string
  front: string
  back: string
}

// luh variables
const sets = ref<Set[]>([])
const selectedSetId = ref<string | null>(null)
const flashcards = ref<Flashcard[]>([])
const currentCardIndex = ref(0)
const showFront = ref(true)
const isFlipped = ref(false)
const showFrontFirst = ref(true)
const error = ref('')

//  load sets from the database
const loadSets = async () => {
  try {
    const { data, error: err } = await supabase
      .from('sets')
      .select('id, name')
      .order('name')

    if (err) throw err
    sets.value = data || []
  } catch (err: any) {
    error.value = err.message
  }
}

//  load flashcards for a selected set
const loadFlashcards = async (setId: string) => {
  try {
    const { data, error: err } = await supabase
      .from('flashcards')
      .select('id, front, back')
      .eq('set_id', setId)

    if (err) throw err
    flashcards.value = data || []
    currentCardIndex.value = 0
    isFlipped.value = false
  } catch (err: any) {
    error.value = err.message
  }
}

// handle set selection
const selectSet = async (setId: string) => {
  selectedSetId.value = setId
  await loadFlashcards(setId)
}

// flip the card
const flipCard = () => {
  isFlipped.value = !isFlipped.value
}

// next card
const nextCard = () => {
  if (currentCardIndex.value < flashcards.value.length - 1) {
    currentCardIndex.value++
    isFlipped.value = false
  }
}

// previous card
const previousCard = () => {
  if (currentCardIndex.value > 0) {
    currentCardIndex.value--
    isFlipped.value = false
  }
}

// reset
const resetStudy = () => {
  currentCardIndex.value = 0
  isFlipped.value = false
}

// Load sets when the component is mounted
onMounted(() => {
  loadSets()
})
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <div class="mb-8">
      <h2 class="text-2xl font-bold mb-4">Study Flashcards</h2>
      
      <!-- choose set -->
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">Select Set to Study</label>
        <select
          v-model="selectedSetId"
          @change="selectSet($event.target.value)"
          class="w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        >
          <option value="">Choose a set</option>
          <option v-for="set in sets" :key="set.id" :value="set.id">
            {{ set.name }}
          </option>
        </select>
      </div>

      <!-- display things -->
      <div v-if="selectedSetId" class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">Show First</label>
        <div class="flex gap-4">
          <label class="inline-flex items-center">
            <input
              type="radio"
              v-model="showFrontFirst"
              :value="true"
              class="form-radio"
            >
            <span class="ml-2">Front</span>
          </label>
          <label class="inline-flex items-center">
            <input
              type="radio"
              v-model="showFrontFirst"
              :value="false"
              class="form-radio"
            >
            <span class="ml-2">Back</span>
          </label>
        </div>
      </div>
    </div>

    <!-- show cards -->
    <div v-if="selectedSetId && flashcards.length > 0" class="mb-8">
      <div 
        class="bg-white rounded-xl shadow-lg p-8 cursor-pointer min-h-[300px] flex items-center justify-center transform transition-transform duration-500"
        :class="{ 'scale-[0.97]': isFlipped }"
        @click="flipCard"
      >
        <div class="text-center">
          <p class="text-sm text-gray-500 mb-4">
            Card {{ currentCardIndex + 1 }} of {{ flashcards.length }}
          </p>
          <p class="text-xl">
            {{ isFlipped
              ? (showFrontFirst ? flashcards[currentCardIndex].back : flashcards[currentCardIndex].front)
              : (showFrontFirst ? flashcards[currentCardIndex].front : flashcards[currentCardIndex].back)
            }}
          </p>
          <p class="text-sm text-gray-500 mt-4">Click to flip</p>
        </div>
      </div>

      <div class="flex justify-between items-center mt-6">
        <button
          @click="previousCard"
          :disabled="currentCardIndex === 0"
          class="px-4 py-2 bg-gray-200 rounded-md disabled:opacity-50"
        >
          Previous
        </button>
        <button
          @click="resetStudy"
          class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          Reset
        </button>
        <button
          @click="nextCard"
          :disabled="currentCardIndex === flashcards.length - 1"
          class="px-4 py-2 bg-gray-200 rounded-md disabled:opacity-50"
        >
          Next
        </button>
      </div>
    </div>

    <div v-else-if="selectedSetId" class="text-center text-gray-500">
      No flashcards in this set. Add some flashcards first!
    </div>

    <div v-if="error" class="text-red-600 mt-4">{{ error }}</div>
  </div>
</template>

<style scoped>
</style>