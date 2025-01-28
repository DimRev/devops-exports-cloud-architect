import { useEffect, useState } from 'react';

export function useGetTodos() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getTodos();
  }, []);

  async function getTodos() {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/v1/todo`
      );
      const data = (await response.json()) as { todos: Todo[] };
      setTodos(data.todos);
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

  return { todos, setTodos, isLoading, error };
}
