<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

interface Set {
  id: string
  name: string
  description: string
  created_at: string
}

interface Flashcard {
  id: string
  front: string
  back: string
}

const sets = ref<Set[]>([])
const error = ref('')
const selectedSetId = ref<string | null>(null)
const flashcards = ref<Flashcard[]>([])
const editingSet = ref<Set | null>(null)
const showEditModal = ref(false)
const editedName = ref('')
const editedDescription = ref('')
const menuRefs = ref<{ [key: string]: HTMLElement }>({})
// mrnnu toggler
const toggleMenu = (setId: string, event: Event) => {
  event.stopPropagation()
  const menu = menuRefs.value[setId]
  if (menu) {
    // Close all other menus first
    Object.values(menuRefs.value).forEach(m => {
      if (m !== menu) m.classList.add('hidden')
    })
    // Toggle the clicked menu
    menu.classList.toggle('hidden')
  }
}

// Close menus when clicking outside
const closeMenus = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (!target.closest('.menu-button')) {
    Object.values(menuRefs.value).forEach(menu => menu.classList.add('hidden'))
  }
}
// lod sets
const loadSets = async () => {
  try {
    const { data, error: err } = await supabase
      .from('sets')
      .select('*')
      .order('created_at', { ascending: false })

    if (err) throw err
    sets.value = data
  } catch (err: any) {
    error.value = err.message
  }
}
// choose sets
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
// edit the set
const editSet = (set: Set, event: Event) => {
  event.stopPropagation()
  editingSet.value = set
  editedName.value = set.name
  editedDescription.value = set.description || ''
  showEditModal.value = true
}

const saveEdit = async () => {
  if (!editingSet.value) return

  try {
    const { error: err } = await supabase
      .from('sets')
      .update({
        name: editedName.value.trim(),
        description: editedDescription.value.trim()
      })
      .eq('id', editingSet.value.id)

    if (err) throw err
    
    showEditModal.value = false
    editingSet.value = null
    await loadSets()
  } catch (err: any) {
    error.value = err.message
  }
}

const deleteSet = async (id: string, event: Event) => {
  event.stopPropagation()
  if (!confirm('Are you sure you want to delete this set? All flashcards in this set will also be deleted.')) return

  try {
    // Delete all flashcards in the set first
    const { error: flashcardsErr } = await supabase
      .from('flashcards')
      .delete()
      .eq('set_id', id)

    if (flashcardsErr) throw flashcardsErr

    // Then delete the set
    const { error: setErr } = await supabase
      .from('sets')
      .delete()
      .eq('id', id)

    if (setErr) throw setErr

    await loadSets()
    if (selectedSetId.value === id) {
      selectedSetId.value = null
      flashcards.value = []
    }
  } catch (err: any) {
    error.value = err.message
  }
}

onMounted(() => {
  loadSets()
  document.addEventListener('click', closeMenus)
})
</script>

<template>
  <div class="max-w-4xl mx-auto p-6">
    <h2 class="text-2xl font-bold mb-6">My Flashcard Sets</h2>

    <div v-if="error" class="text-red-600 mb-4">{{ error }}</div>

    <div class="grid grid-cols-1 gap-4">
      <div
        v-for="set in sets"
        :key="set.id"
        class="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow relative group"
        @click="selectSet(set.id)"
      >
        <div class="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
          <div class="relative">
            <button
              class="p-1 hover:bg-gray-100 rounded-full menu-button"
              @click="toggleMenu(set.id, $event)"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
              </svg>
            </button>
            <div
              :ref="el => { if (el) menuRefs[set.id] = el }"
              class="hidden absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-10"
            >
              <div class="py-1">
                <button
                  @click="editSet(set, $event)"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Edit
                </button>
                <button
                  @click="deleteSet(set.id, $event)"
                  class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>

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
    <!-- Editing  -->
    <div v-if="showEditModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-bold mb-4">Edit Set</h3>
        <form @submit.prevent="saveEdit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Set Name</label>
            <input
              v-model="editedName"
              type="text"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              v-model="editedDescription"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              rows="3"
            ></textarea>
          </div>
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="showEditModal = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-md"
            >
              Save
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>