const assetTag = document.getElementById("assetTag");
const borrower = document.getElementById("borrowID");
const returnDate = document.getElementById("returnDate");
const submit = document.getElementById("submit");
const APIurl = `${window.location.protocol}//${window.location.hostname}:9090/api`;
submit.addEventListener("click", function() {
    const loanData = {borrower: borrower.value, dueDate: returnDate.value};
    const url = `${APIurl}/assets/${assetTag.value}/loan`;
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
        submit.innerHTML = "Loan Submitted";
    })
    .catch(error => {
        submit.innerHTML = "Failed to submit";
    });
});