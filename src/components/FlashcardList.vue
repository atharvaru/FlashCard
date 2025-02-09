<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

interface Flashcard {
  id: string
  front: string
  back: string
  created_at: string
  last_reviewed: string | null
}
// some luh variables
const flashcards = ref<Flashcard[]>([])
const error = ref('')
const editingCard = ref<Flashcard | null>(null)
const showEditModal = ref(false)
const editedFront = ref('')
const editedBack = ref('')
const menuRefs = ref<{ [key: string]: HTMLElement }>({})
// 3 dots menu 
const toggleMenu = (cardId: string, event: Event) => {
  event.stopPropagation()
  const menu = menuRefs.value[cardId]
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
// flascards 
const loadFlashcards = async () => {
  try {
    const { data, error: err } = await supabase
      .from('flashcards')
      .select('*')
      .order('created_at', { ascending: false })

    if (err) throw err
    flashcards.value = data
  } catch (err: any) {
    error.value = err.message
  }
}
// changinf the card
const editCard = (card: Flashcard, event: Event) => {
  event.stopPropagation()
  editingCard.value = card
  editedFront.value = card.front
  editedBack.value = card.back
  showEditModal.value = true
}

const saveEdit = async () => {
  if (!editingCard.value) return
// updating the card
  try {
    const { error: err } = await supabase
      .from('flashcards')
      .update({
        front: editedFront.value.trim(),
        back: editedBack.value.trim()
      })
      .eq('id', editingCard.value.id)

    if (err) throw err
    
    showEditModal.value = false
    editingCard.value = null
    await loadFlashcards()
  } catch (err: any) {
    error.value = err.message
  }
}
// gettinf rid of it 
const deleteCard = async (id: string, event: Event) => {
  event.stopPropagation()
  if (!confirm('Are you sure you want to delete this flashcard?')) return

  try {
    const { error: err } = await supabase
      .from('flashcards')
      .delete()
      .eq('id', id)

    if (err) throw err
    await loadFlashcards()
  } catch (err: any) {
    error.value = err.message
  }
}

onMounted(() => {
  loadFlashcards()
  document.addEventListener('click', closeMenus)
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
        class="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow relative group"
      >
        <div class="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
          <div class="relative">
            <button
              class="p-1 hover:bg-gray-100 rounded-full menu-button"
              @click="toggleMenu(card.id, $event)"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
              </svg>
            </button>
            <div
              :ref="el => { if (el) menuRefs[card.id] = el }"
              class="hidden absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-10"
            >
              <div class="py-1">
                <button
                  @click="editCard(card, $event)"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Edit
                </button>
                <button
                  @click="deleteCard(card.id, $event)"
                  class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>

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

    <!-- Edit-->
    <div v-if="showEditModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-bold mb-4">Edit Flashcard</h3>
        <form @submit.prevent="saveEdit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Front</label>
            <textarea
              v-model="editedFront"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              rows="3"
            ></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Back</label>
            <textarea
              v-model="editedBack"
              required
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