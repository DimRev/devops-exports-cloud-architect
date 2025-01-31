import { useState } from 'react';

export function usePutItem() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function putItem(
    id: string,
    name: string,
    description: string,
    setItems: React.Dispatch<React.SetStateAction<Item[]>>
  ) {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/items/${id}`,
        {
          headers: { 'Content-Type': 'application/json' },
          method: 'PUT',
          body: JSON.stringify({ name, description }),
        }
      );

      if (!response.ok) throw new Error('Failed to update item');

      const { message, item: updatedItem } = await response.json();

      console.log(message);

      setItems((prevItems) =>
        prevItems.map((item) =>
          item._id === updatedItem._id ? { ...item, ...updatedItem } : item
        )
      );
    } catch (error) {
      setError(error instanceof Error ? error.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  return { putItem, isLoading, error };
}
