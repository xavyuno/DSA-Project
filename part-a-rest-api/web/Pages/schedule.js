const assetTag = document.getElementById("assetTag");
const scheduleID = document.getElementById("scheduleID");
const dueDate = document.getElementById("dueDate");
const description = document.getElementById("description");
const submit = document.getElementById("submit");
submit.addEventListener("click", function() {
    const Data = {
        scheduleId: scheduleID.value,
        'type': "SERVICING",
        dueDate: dueDate.value,
        description: description.value
    };
    const url = `http://localhost:9090/api/assets/${assetTag.value}/schedules`;
    console.log("url:", url);
    fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(Data)
    })
    .then(response => response.json())
    .then(data => {
        submit.innerHTML = "Schedule Submitted";
    })
    .catch(error => {
        submit.innerHTML = "Failed to submit schedule";
    });
});