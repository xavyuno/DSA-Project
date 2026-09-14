fetch("http://localhost:9090/api/assets")
  .then(response => response.json())
  .then(assets => {
      const select = document.getElementById("assetTag");
      select.innerHTML = "";
      for (const asset of assets) {
          const option = document.createElement("option");
          option.value = asset.assetTag;
          option.textContent = asset.assetTag;
          select.appendChild(option);
      }
  })
  .catch(err => console.error("Failed to load assets:", err));