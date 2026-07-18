// tree_selection.js - lets the user double-click a target-tree card,
// pick a level, and open that tree's live preview page.
//
// Uses event delegation on the parent containers (.scroll-container,
// #level-container) instead of wiring each card individually, since
// the cards are created asynchronously by tree_thumbnail.js
// and may not exist yet when this script runs.

const scrollContainer = document.querySelector(".scroll-container");
const levelWindow = document.getElementById("centered-container-level");
const levelContainer = document.getElementById("level-container");
const okButton = document.getElementById("ok-button");
const zurueckButton = document.getElementById("zurück");

let selectedTreeId = null;
let selectedLevel = null;

function resetSelection() {
    selectedTreeId = null;
    selectedLevel = null;

    for (const level of levelContainer.querySelectorAll(".level")) {
        level.classList.remove("active");
    }
}

// double-click a card -> remember its tree id, open the level window
scrollContainer.addEventListener("dblclick", (event) => {
    const card = event.target.closest(".card");
    if (!card) {
        return;
    }

    selectedTreeId = card.id.replace("card-", "");
    levelWindow.classList.add("is-open");
});

// click a level -> select it exclusively
levelContainer.addEventListener("click", (event) => {
    const level = event.target.closest(".level");
    if (!level) {
        return;
    }

    for (const other of levelContainer.querySelectorAll(".level")) {
        other.classList.toggle("active", other === level);
    }

    selectedLevel = level.id.replace("level-", "");
});

// OK -> navigate to the live preview page for the chosen tree + level
okButton.addEventListener("click", () => {
    if (selectedTreeId === null || selectedLevel === null) {
        console.warn("Pick a level before continuing.");
        return;
    }

    const params = new URLSearchParams({ tree: selectedTreeId, level: selectedLevel });
    window.location.href = `tree_preview.html?${params}`;
});

// zurück -> close the window, let the user pick another card
zurueckButton.addEventListener("click", () => {
    levelWindow.classList.remove("is-open");
    resetSelection();
});
