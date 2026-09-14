const checkDate = document.getElementById("checkDate");
const submit = document.getElementById("submit");
submit.addEventListener("click", function() {
    const url = `http://localhost:9090/api/overdue?asOf=${checkDate.value}`;
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
    .then(data => {
        submit.innerHTML = "Assets Retrieved";
    })
    .catch(error => {
        submit.innerHTML = "Failed to retrieve overdue assets";
    });
});
