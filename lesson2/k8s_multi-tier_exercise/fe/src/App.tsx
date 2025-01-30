import { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_URL;

function App() {
  const [key, setKey] = useState('');
  const [value, setValue] = useState('');
  const [retrievedValue, setRetrievedValue] = useState('');
  const [status, setStatus] = useState('');

  // Fetch backend status on mount
  useEffect(() => {
    fetch(`${API_URL}/`)
      .then((res) => res.json())
      .then((data) => setStatus(data.message))
      .catch(() => setStatus('Error connecting to backend'));
  }, []);

  // Function to set a key-value pair in Redis
  const handleSet = async () => {
    if (!key || !value) return alert('Please enter both key and value');
    try {
      const response = await fetch(`${API_URL}/set/${key}/${value}`);
      const data = await response.json();
      alert(data.message);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err) {
      alert('Failed to set value in Redis');
    }
  };

  // Function to retrieve a value from Redis
  const handleGet = async () => {
    if (!key) return alert('Please enter a key to retrieve');
    try {
      const response = await fetch(`${API_URL}/get/${key}`);
      const data = await response.json();
      if (data.error) {
        alert(data.error);
        setRetrievedValue('');
      } else {
        setRetrievedValue(data[key]);
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err) {
      alert('Failed to get value from Redis');
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Multi-Tier App</h1>
      <p>Status: {status}</p>

      <div style={{ marginBottom: '10px' }}>
        <input
          type="text"
          placeholder="Key"
          value={key}
          onChange={(e) => setKey(e.target.value)}
          style={{ marginRight: '10px' }}
        />
        <input
          type="text"
          placeholder="Value"
          value={value}
          onChange={(e) => setValue(e.target.value)}
        />
      </div>

      <div>
        <button onClick={handleSet} style={{ marginRight: '10px' }}>
          Set Key
        </button>
        <button onClick={handleGet}>Get Key</button>
      </div>

      {retrievedValue && (
        <p>
          Retrieved Value: <strong>{retrievedValue}</strong>
        </p>
      )}
    </div>
  );
}

export default App;
