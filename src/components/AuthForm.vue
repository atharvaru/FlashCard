<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '../lib/supabase'

// Define reactive variables for email, password, error message, and loading state
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

// Function to handle sign-up form submission
const handleSubmit = async () => {
  try {
    loading.value = true // Set loading state to true
    const { error: err } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
    })
    if (err) throw err // Throw error if sign-up fails
  } catch (err: any) {
    error.value = err.message // Set error message
  } finally {
    loading.value = false // Reset loading state
  }
}

// Function to handle sign-in form submission
const handleSignIn = async () => {
  try {
    loading.value = true // Set loading state to true
    const { error: err } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    if (err) throw err // Throw error if sign-in fails
  } catch (err: any) {
    error.value = err.message // Set error message
  } finally {
    loading.value = false // Reset loading state
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Sign in to your account
        </h2>
      </div>
      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="email-address" class="sr-only">Email address</label>
            <input
              id="email-address"
              name="email"
              type="email"
              required
              v-model="email"
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="Email address"
            />
          </div>
          <div>
            <label for="password" class="sr-only">Password</label>
            <input
              id="password"
              name="password"
              type="password"
              required
              v-model="password"
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="Password"
            />
          </div>
        </div>

        <div class="flex justify-between">
          <button
            type="button"
            @click="handleSignIn"
            :disabled="loading"
            class="group relative w-1/2 mr-2 flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Sign in
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-1/2 ml-2 flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            Sign up
          </button>
        </div>

        <div v-if="error" class="text-red-600 text-center">{{ error }}</div>
      </form>
    </div>
  </div>
</template>