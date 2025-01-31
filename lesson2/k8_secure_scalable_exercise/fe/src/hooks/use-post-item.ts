import { useState } from 'react';

export function usePostItem() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function postItem(
    name: string,
    description: string,
    setItems: React.Dispatch<React.SetStateAction<Item[]>>
  ) {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/items`,
        {
          headers: {
            'Content-Type': 'application/json',
            'X-API-KEY': import.meta.env.VITE_API_KEY,
          },
          method: 'POST',
          body: JSON.stringify({ name, description }),
        }
      );

      if (!response.ok) throw new Error('Failed to create item');

      const { message, item: newItem } = await response.json();

      console.log(message);

      setItems((prevItems) => [...prevItems, newItem]);
    } catch (error) {
      setError(error instanceof Error ? error.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  return { postItem, isLoading, error };
}
