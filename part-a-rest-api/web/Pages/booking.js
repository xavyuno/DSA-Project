const roomTag = document.getElementById("roomTag");
const bookedID = document.getElementById("bookedID");
const bookingStartDate = document.getElementById("bookingStartDate");
const bookingEndDate = document.getElementById("bookingEndDate");
const submit = document.getElementById("submit");
submit.addEventListener("click", function() {
    const loanData = {
        bookedBy: bookedID.value,
        startDate: bookingStartDate.value,
        endDate: bookingEndDate.value,
        description: "Client booking"
    };
    const url = `http://localhost:9090/api/assets/${roomTag.value}/book`;
    console.log("url:", url);
    fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(loanData)
    })
    .then(response => response.json())
    .then(data => {
        submit.innerHTML = "Booking Submitted";
    })
    .catch(error => {
        submit.innerHTML = "Failed to submit booking";
    });
});