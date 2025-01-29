import { useState } from 'react'

export function useDeleteTodo() {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function deleteTodo(
    id: number,
    setTodos: React.Dispatch<React.SetStateAction<Todo[]>>,
  ) {
    setIsLoading(true)
    setError(null)

    try {
      setTodos((prevTodos) => prevTodos.filter((todo) => todo.id !== id)) // Optimistically update
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/v1/todo/${id}`,
        {
          headers: {
            'Content-Type': 'application/json',
            'X-API-KEY': import.meta.env.VITE_API_KEY,
          },
          method: 'DELETE',
        },
      )

      if (!response.ok) {
        throw new Error('Failed to delete todo')
      }

      return 'Deleted successfully'
    } catch (error) {
      if (error instanceof Error) {
        setError(error.message)
      } else {
        setError('An error occurred')
      }
    } finally {
      setIsLoading(false)
    }
  }

  return { deleteTodo, isLoading, error }
}
