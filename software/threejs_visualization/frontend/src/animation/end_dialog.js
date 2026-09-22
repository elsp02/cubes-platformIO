// end_dialog.js - confirmation overlay for bauen.html 
// Used for when 
//    - building process is aborted
//    - building process is finished - fully built

const overlay = document.getElementById("end-overlay");
const messageEl = document.getElementById("end-message");
const buttonContainer = document.getElementById("end-button-container");
const cancelButton = document.getElementById("end-cancel-button");
const confirmButton = document.getElementById("end-confirm-button");

let onConfirm = null;

// closeEndDialog
// - closes the overlay and clears the pending confirm callback
export function closeEndDialog() {
    overlay.classList.remove("is-open");
    onConfirm = null;
}

// openEndDialog
// - shows the overlay with the given message; confirmCallback runs on Haken
// - allowCancel = false hides the Kreuz button and centers the
//   remaining Haken button (used for the "fully built" case)
export function openEndDialog(message, confirmCallback, allowCancel = true) {
    messageEl.textContent = message;
    onConfirm = confirmCallback;

    cancelButton.classList.toggle("hidden", !allowCancel);
    buttonContainer.classList.toggle("center", !allowCancel);

    overlay.classList.add("is-open");
}

cancelButton.addEventListener("click", closeEndDialog);

confirmButton.addEventListener("click", () => {
    onConfirm?.();
    closeEndDialog();
});
