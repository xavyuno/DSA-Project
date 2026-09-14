const campusCode = document.getElementById("campusCode");
const site = document.getElementById("site");
const submit = document.getElementById("submit");
submit.addEventListener("click", function() {
    var url = `http://localhost:9090/api/assets?institution=${campusCode.value}`;
    if (site.value != "") {
        url += `&site=${site.value}`;
    }
    fetch(url)
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
    .catch(error => {
        submit.innerHTML = "Failed to retrieve assets";
    });
});
