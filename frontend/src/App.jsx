import React, { useEffect, useState } from "react";
import API_URL from "./api.jsx";

function App() {
  const [users, setUsers] = useState([]);
  const [name, setName] = useState("");

  const loadUsers = async () => {
    const res = await fetch(`${API_URL}/users`);
    const data = await res.json();
    setUsers(data);
  };

  const addUser = async () => {
    if (!name) return;
    await fetch(`${API_URL}/users`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
    });
    setName("");
    loadUsers();
  };

  const deleteUser = async (id) => {
    await fetch(`${API_URL}/users/${id}`, { method: "DELETE" });
    loadUsers();
  };

  useEffect(() => {
    loadUsers();
  }, []);

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h2>Simple CRUD App</h2>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter user name"
      />
      <button onClick={addUser}>Add User</button>

      <ul>
        {users.map((u) => (
          <li key={u.id}>
            {u.name} <button onClick={() => deleteUser(u.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
