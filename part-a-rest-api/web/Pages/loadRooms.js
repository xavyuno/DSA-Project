fetch("http://localhost:9090/api/assets?institution")
  .then(response => response.json())
  .then(assets => {
      var loadedAssets = [];
      const select = document.getElementById("roomTag");
      select.innerHTML = "";
      for (const asset of assets) {
        if (loadedAssets.includes(asset.site)) {
            continue;
        }
        console.log("Asset:", asset.site);
        loadedAssets.push(asset.site);
        const option = document.createElement("option");
        option.value = asset.site;
        option.textContent = asset.site;
        select.appendChild(option);
      }
  })
  .catch(err => console.error("Failed to load assets:", err));