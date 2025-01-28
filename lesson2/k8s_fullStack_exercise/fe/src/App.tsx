import { useDeleteTodo } from './hooks/use-delete-todo';
import { useGetTodos } from './hooks/use-get-todos';
import { usePostTodo } from './hooks/use-post-todo';
import { usePutTodo } from './hooks/use-put.todo';

function App() {
  const { todos, setTodos, isLoading, error } = useGetTodos();
  const { postTodo, isLoading: isPosting, error: postError } = usePostTodo();
  const { deleteTodo, isLoading: isDeleting } = useDeleteTodo();
  const { putTodo, isLoading: isPutting } = usePutTodo();

  function handleCreateTodo(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const title = formData.get('title') as string;
    const description = formData.get('description') as string;

    postTodo(title, description, setTodos);
  }

  function handleDeleteTodo(id: number) {
    deleteTodo(id, setTodos);
  }

  function handleUpdateTodo(id: number, title: string, description?: string) {
    putTodo(id, title, description || '', setTodos);
  }

  return (
    <div>
      <h2>Todos</h2>
      {isLoading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error}</p>
      ) : (
        <ul>
          {todos.map((todo) => (
            <li key={todo.id}>
              <h3>{todo.title}</h3>
              <p>{todo.description}</p>
              <button
                onClick={() => handleDeleteTodo(todo.id)}
                disabled={isDeleting}
              >
                {isDeleting ? 'Deleting...' : 'Delete'}
              </button>
              <button
                onClick={() =>
                  handleUpdateTodo(
                    todo.id,
                    prompt('Edit title', todo.title) || todo.title,
                    prompt('Edit description', todo.description) ||
                      todo.description
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
      <h2>Create Todo</h2>
      {postError && <p>Error: {postError}</p>}
      <form onSubmit={handleCreateTodo}>
        <input type="text" name="title" placeholder="Title" required />
        <input type="text" name="description" placeholder="Description" />
        <button type="submit" disabled={isPosting}>
          {isPosting ? 'Creating...' : 'Create'}
        </button>
      </form>
    </div>
  );
}

export default App;
