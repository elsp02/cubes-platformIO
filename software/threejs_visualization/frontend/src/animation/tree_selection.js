// tree_selection.js - lets the user 
//    - click a target-tree card
//    - pick a level
//    - and open that tree's live preview page
//
// Level selection is not used yet -  only a draft (see commented out code below)

import { showTargetTreePreview } from "../visualization/tree_preview.js";

const scrollContainer = document.querySelector("#scroll-container-dashboard");
const levelWindow = document.getElementById("preview-overlay");
const levelContainer = document.getElementById("level-container");
const okButton = document.getElementById("ok-button");
const backButton = document.getElementById("zurück-button");
const dotsContainer = document.getElementById("dots-container");

let cards = [];
let dots = [];
let scrollTicking = false;

let selectedTreeId = null;
let selectedLevel = null;

// resetSelection
// - clears the current tree/level selection
function resetSelection() {
    selectedTreeId = null;
    selectedLevel = null;

    // level selection currently unused - see #level-container in index.html
    // for (const level of levelContainer.querySelectorAll(".level")) {
    //     level.classList.remove("active");
    // }
}

// updateActiveCard
// - finds whichever card's center is closest to the container's center
//   -> marks it as active
function updateActiveCard() {
    if (cards.length === 0) {
        return;
    }

    const containerRect = scrollContainer.getBoundingClientRect();
    const containerCenter = containerRect.left + containerRect.width / 2;

    let closestIndex = 0;
    let closestDistance = Infinity;

    cards.forEach((card, index) => {
        const cardRect = card.getBoundingClientRect();
        const cardCenter = cardRect.left + cardRect.width / 2;
        const distance = Math.abs(cardCenter - containerCenter);

        if (distance < closestDistance) {
            closestDistance = distance;
            closestIndex = index;
        }
    });

    cards.forEach((card, index) => card.classList.toggle("is-active", index === closestIndex));
    dots.forEach((dot, index) => dot.classList.toggle("is-active", index === closestIndex));
}

// onScroll
// - throttles scroll updates to one per animation frame
function onScroll() {
    if (scrollTicking) {
        return;
    }
    scrollTicking = true;
    requestAnimationFrame(() => {
        updateActiveCard();
        scrollTicking = false;
    });
}

// initCarousel
// - builds the dots once the cards exist, then starts tracking scroll position
function initCarousel() {
    cards = Array.from(scrollContainer.querySelectorAll(".card"));
    if (cards.length === 0) {
        return;
    }

    dotsContainer.innerHTML = "";
    dots = cards.map((card) => {
        const dot = document.createElement("button");
        dot.type = "button";
        dot.className = "dot";
        dot.addEventListener("click", () => {
            card.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
        });
        dotsContainer.append(dot);
        return dot;
    });

    scrollContainer.addEventListener("scroll", onScroll, { passive: true });
    updateActiveCard();
}

document.addEventListener("cards-ready", initCarousel);


// click a card -> remember its tree id, open the level window
scrollContainer.addEventListener("click", (event) => {
    const card = event.target.closest(".card");
    if (!card) {
        return;
    }

    selectedTreeId = card.id.replace("card-", "");
    levelWindow.classList.add("is-open");
    showTargetTreePreview(selectedTreeId);
});

// click a level -> select it exclusively
// level selection currently unused - see #level-container in index.html
// levelContainer.addEventListener("click", (event) => {
//     const level = event.target.closest(".level");
//     if (!level) {
//         return;
//     }
//
//     for (const other of levelContainer.querySelectorAll(".level")) {
//         other.classList.toggle("active", other === level);
//     }
//
//     selectedLevel = level.id.replace("level-", "");
// });

// OK -> navigate to the live build page -> connects to the WebSocket server 
// for real cube comparison
okButton.addEventListener("click", () => {
    if (selectedTreeId === null) {
        console.warn("Pick a construction before continuing.");
        return;
    }

    // level selection currently unused, so it's left out of the params;
    // originally required selectedLevel too:
    // const params = new URLSearchParams({ tree: selectedTreeId, level: selectedLevel });
    const params = new URLSearchParams({ tree: selectedTreeId });
    window.location.href = `build_reference.html?${params}`;
});

// back -> close the window, let the user pick another card
backButton.addEventListener("click", () => {
    levelWindow.classList.remove("is-open");
    resetSelection();
});
