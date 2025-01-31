import { useState } from 'react';

export function useDeleteItem() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function deleteItem(
    id: string,
    setItems: React.Dispatch<React.SetStateAction<Item[]>>
  ) {
    setIsLoading(true);
    setError(null);

    try {
      setItems((prevItems) => prevItems.filter((item) => item._id !== id)); // Optimistic update
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/items/${id}`,
        {
          headers: {
            'Content-Type': 'application/json',
            'X-API-KEY': import.meta.env.VITE_API_KEY,
          },
          method: 'DELETE',
        }
      );

      if (!response.ok) throw new Error('Failed to delete item');
    } catch (error) {
      setError(error instanceof Error ? error.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  return { deleteItem, isLoading, error };
}
