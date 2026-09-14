const assetTag = document.getElementById("assetTag");
const borrower = document.getElementById("borrowID");
const returnDate = document.getElementById("returnDate");
const submit= document.getElementById("submitLoan");
submitLoan.addEventListener("click", function() {
    const loanData = {borrower: borrower.value, dueDate: returnDate.value};
    const url = `http://localhost:9090/api/assets/${assetTag.value}/loan`;
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
        submitloan.innerHTML = "Loan Submitted";
    })
    .catch(error => {
        submit.innerHTML = "Failed to submit";
    });
});