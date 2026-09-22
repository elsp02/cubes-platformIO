// end_dialog.js - confirmation overlay for bauen.html. Same visual
// pattern as the dashboard's preview overlay (blurred background, a
// centered box, Kreuz/Haken buttons).
//
// Used for two cases that share one dialog:
//   - the user clicks the header X mid-build ("Wirklich beenden?",
//     both buttons: Kreuz cancels and closes the dialog, Haken confirms)
//   - the construction is fully built ("Fertig, gut gemacht!", only
//     the Haken button - there is nothing to cancel)

const overlay = document.getElementById("end-overlay");
const messageEl = document.getElementById("end-message");
const buttonContainer = document.getElementById("end-button-container");
const cancelButton = document.getElementById("end-cancel-button");
const confirmButton = document.getElementById("end-confirm-button");

let onConfirm = null;

export function closeEndDialog() {
    overlay.classList.remove("is-open");
    onConfirm = null;
}

// allowCancel = false hides the Kreuz button and centers the
// remaining Haken button (used for the "fully built" case)
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
