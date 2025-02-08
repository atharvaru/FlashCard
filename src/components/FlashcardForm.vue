<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

// input and messages forms variables
const front = ref('')
const back = ref('')
const setId = ref('')
const error = ref('')
const success = ref('')
const sets = ref([])

// Function to load available sets from the database
const loadSets = async () => {
  try {
    const { data, error: err } = await supabase
      .from('sets')
      .select('id, name')
      .order('name')

    if (err) throw err
    sets.value = data
  } catch (err: any) {
    error.value = err.message
  }
}

// Function to create a new flashcard
const createFlashcard = async () => {
  try {
    const trimmedFront = front.value.trim()
    const trimmedBack = back.value.trim()

    // Validate form inputs
    if (!trimmedFront || !trimmedBack) {
      throw new Error('Both front and back of the flashcard are required')
    }

    if (!setId.value) {
      throw new Error('Please select a set for this flashcard')
    }

    // Get the user data
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      throw new Error('User not authenticated')
    }

    // Insert the new flashcard into the database
    const { error: err } = await supabase
      .from('flashcards')
      .insert([{
        front: trimmedFront,
        back: trimmedBack,
        user_id: user.id,
        set_id: setId.value
      }])

    if (err) throw err

  
    front.value = ''
    back.value = ''
    error.value = ''
  } catch (err: any) {
    error.value = err.message
    success.value = ''
  }
}

// Load sets when the component is mounted
onMounted(() => {
  loadSets()
})
</script>

<template>
  <div class="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-4">Create New Flashcard</h2>
    
    <form @submit.prevent="createFlashcard" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700">Select Set</label>
        <select
          v-model="setId"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        >
          <option value="">Choose a set</option>
          <option v-for="set in sets" :key="set.id" :value="set.id">
            {{ set.name }}
          </option>
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Front</label>
        <textarea
          v-model="front"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          rows="3"
        ></textarea>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Back</label>
        <textarea
          v-model="back"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          rows="3"
        ></textarea>
      </div>

      <button
        type="submit"
        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Create Flashcard
      </button>
    </form>

    <p v-if="error" class="mt-2 text-red-600">{{ error }}</p>
    <p v-if="success" class="mt-2 text-green-600">{{ success }}</p>
  </div>
</template>