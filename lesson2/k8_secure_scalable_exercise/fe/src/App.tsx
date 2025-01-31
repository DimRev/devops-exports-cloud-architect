import { useDeleteItem } from './hooks/use-delete-item';
import { useGetItems } from './hooks/use-get-items';
import { usePostItem } from './hooks/use-post-item';
import { usePutItem } from './hooks/use-put-item';

function App() {
  const { items, setItems, isLoading, error } = useGetItems();
  const { postItem, isLoading: isPosting, error: postError } = usePostItem();
  const { deleteItem, isLoading: isDeleting } = useDeleteItem();
  const { putItem, isLoading: isPutting } = usePutItem();

  function handleCreateItem(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const name = formData.get('name') as string;
    const description = formData.get('description') as string;

    postItem(name, description, setItems);
  }

  function handleDeleteItem(id: string) {
    deleteItem(id, setItems);
  }

  function handleUpdateItem(id: string, name: string, description?: string) {
    putItem(id, name, description || '', setItems);
  }

  return (
    <div className="app">
      <h2>Items</h2>
      <div className="items-container">
        {isLoading ? (
          <p>Loading...</p>
        ) : error ? (
          <p>Error: {error}</p>
        ) : (
          <ul>
            {items.map((item) => (
              <li key={item._id}>
                <h3>{item.name}</h3>
                <p>{item.description}</p>
                <button
                  onClick={() => handleDeleteItem(item._id)}
                  disabled={isDeleting}
                >
                  {isDeleting ? 'Deleting...' : 'Delete'}
                </button>
                <button
                  onClick={() =>
                    handleUpdateItem(
                      item._id,
                      prompt('Edit name', item.name) || item.name,
                      prompt('Edit description', item.description) ||
                        item.description
                    )
                  }
                  disabled={isPutting}
                >
                  {isPutting ? 'Updating...' : 'Update'}
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
      <div className="create-item-container">
        <h2>Create Item</h2>
        {postError && <p>Error: {postError}</p>}
        <form onSubmit={handleCreateItem} className="create-item-form">
          <input type="text" name="name" placeholder="Name" required />
          <input type="text" name="description" placeholder="Description" />
          <button type="submit" disabled={isPosting}>
            {isPosting ? 'Creating...' : 'Create'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default App;
