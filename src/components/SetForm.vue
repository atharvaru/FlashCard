<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '../lib/supabase'

const name = ref('')
const description = ref('')
const error = ref('')
const success = ref('')

// Funct to create a new set
const createSet = async () => {
  try {
    // Trim whitespace from input values
    const trimmedName = name.value.trim()
    const trimmedDescription = description.value.trim()

    // Check if the set name is provided
    if (!trimmedName) {
      throw new Error('Set name is required')
    }

    // Get the user
    const { data: { user } } = await supabase.auth.getUser()
    
    // Check if user authenticated
    if (!user) {
      throw new Error('User not authenticated')
    }

    // Insert the new set into the 'sets' table in the database
    const { error: err } = await supabase
      .from('sets')
      .insert([{
        name: trimmedName, // Set name
        description: trimmedDescription, // Set description
        user_id: user.id // ID of the authenticated user
      }])

    // error if the insertion fails
    if (err) throw err

    // Set success message and clear form inputs
    success.value = 'Set created successfully!'
    name.value = ''
    description.value = ''
    error.value = ''
  } catch (err: any) {
    // Set error message 
    error.value = err.message
    success.value = ''
  }
}
</script>

<template>
  <div class="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-4">Create New Set</h2>
    
    <form @submit.prevent="createSet" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700">Set Name</label>
        <input
          v-model="name"
          type="text"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Description</label>
        <textarea
          v-model="description"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          rows="3"
        ></textarea>
      </div>

      <button
        type="submit"
        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Create Set
      </button>
    </form>

    <p v-if="error" class="mt-2 text-red-600">{{ error }}</p>
    <p v-if="success" class="mt-2 text-green-600">{{ success }}</p>
  </div>
</template>