import { useState } from 'react'

export function usePutTodo() {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function putTodo(
    id: number,
    title: string,
    description: string,
    setTodos: React.Dispatch<React.SetStateAction<Todo[]>>,
  ) {
    setIsLoading(true)
    setError(null)

    try {
      setTodos((prevTodos) =>
        prevTodos.map((todo) =>
          todo.id === id ? { ...todo, title, description } : todo,
        ),
      ) // Optimistically update
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/v1/todo/${id}`,
        {
          headers: {
            'Content-Type': 'application/json',
            'X-API-KEY': import.meta.env.VITE_API_KEY,
          },
          method: 'PUT',
          body: JSON.stringify({ title, description }),
        },
      )

      if (!response.ok) {
        throw new Error('Failed to update todo')
      }

      const data = (await response.json()) as Todo
      return data
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

  return { putTodo, isLoading, error }
}
