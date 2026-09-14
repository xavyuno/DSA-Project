
const API = `${window.location.protocol}//${window.location.hostname}:9090/api`;
fetch(`${API}/assets?institution`)
  .then(response => response.json())
  .then(assets => {
      var loadedAssets = [];
      const select = document.getElementById("campusCode");
      select.innerHTML = "";
      for (const asset of assets) {
        if (loadedAssets.includes(asset.institution)) {
            continue;
        }
        console.log("Asset:", asset.institution);
        loadedAssets.push(asset.institution);
        const option = document.createElement("option");
        option.value = asset.institution;
        option.textContent = asset.institution;
        select.appendChild(option);
      }
  })
  .catch(err => console.error("Failed to load assets:", err));