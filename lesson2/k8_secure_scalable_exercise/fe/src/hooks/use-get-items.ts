import { useEffect, useState } from 'react';

export function useGetItems() {
  const [items, setItems] = useState<Item[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getItems();
  }, []);

  async function getItems() {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/api/items`,
        {
          headers: { 'Content-Type': 'application/json' },
        }
      );
      const data = await response.json();

      setItems(data);
    } catch (error) {
      setError(error instanceof Error ? error.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  }

  return { items, setItems, isLoading, error };
}
