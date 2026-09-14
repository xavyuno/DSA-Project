fetch("http://localhost:9090/api/assets")
  .then(response => response.json())
  .then(assets => {
      const tbody = document.getElementById("globalTable");
      tbody.innerHTML = "";
      for (const asset of assets) {
          const row = document.createElement("tr");
          row.innerHTML = `
              <td>${asset.assetTag}</td>
              <td>${asset.name}</td>
              <td>${asset.institution}</td>
              <td>${asset.site}</td>
              <td>${asset.status}</td>
          `;
          tbody.appendChild(row);
      }
  })
  .catch(err => console.error("Failed to load assets:", err));