import { useState } from 'react';

export function usePostTodo() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function postTodo(
    title: string,
    description: string,
    setTodos: React.Dispatch<React.SetStateAction<Todo[]>>
  ) {
    setIsLoading(true);
    setError(null);

    const newTodo: Todo = {
      id: Date.now(), // Temporary optimistic ID
      title,
      description,
    };

    try {
      setTodos((prevTodos) => [...prevTodos, newTodo]); // Optimistically update
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/v1/todo`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ title, description }),
        }
      );

      if (!response.ok) {
        throw new Error('Failed to create todo');
      }

      const data = (await response.json()) as Todo;
      setTodos((prevTodos) =>
        prevTodos.map((todo) => (todo.id === newTodo.id ? data : todo))
      ); // Replace the temporary todo with the server response
      return data;
    } catch (error) {
      if (error instanceof Error) {
        setError(error.message);
      } else {
        setError('An error occurred');
      }
    } finally {
      setIsLoading(false);
    }
  }

  return { postTodo, isLoading, error };
}
