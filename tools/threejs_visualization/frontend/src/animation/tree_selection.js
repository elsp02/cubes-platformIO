// tree_selection.js - lets the user double-click a target-tree card,
// pick a level, and open that tree's live preview page.
//
// Uses event delegation on the parent containers (.scroll-container,
// #level-container) instead of wiring each card individually, since
// the cards are created asynchronously by selected_tree_visualization.js
// and may not exist yet when this script runs.

import { showTargetTreePreview } from "../visualization/tree_preview.js";

const scrollContainer = document.querySelector("#scroll-container-dashboard");
const levelWindow = document.getElementById("preview-overlay");
const levelContainer = document.getElementById("level-container");
const okButton = document.getElementById("ok-button");
const zurueckButton = document.getElementById("zurück-button");
const dotsContainer = document.getElementById("dots-container");

let cards = [];
let dots = [];
let scrollTicking = false;

let selectedTreeId = null;
let selectedLevel = null;

function resetSelection() {
    selectedTreeId = null;
    selectedLevel = null;

    for (const level of levelContainer.querySelectorAll(".level")) {
        level.classList.remove("active");
    }
}

//--------------------------------
// find whichever card's center is closest to the container's center
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

// throttle scroll updates to one per animation frame
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

// build the dots once the cards exist, then start tracking scroll position
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
//initCarousel();
//------------------------------------
// double-click a card -> remember its tree id, open the level window
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

// OK -> navigate to the fullscreen target-tree page.
// bauen.html remains available as the live evaluated-tree alternative.
okButton.addEventListener("click", () => {
    if (selectedTreeId === null || selectedLevel === null) {
        console.warn("Pick a level before continuing.");
        return;
    }

    const params = new URLSearchParams({ tree: selectedTreeId, level: selectedLevel });
    window.location.href = `bauen_target.html?${params}`;
});

// zurück -> close the window, let the user pick another card
zurueckButton.addEventListener("click", () => {
    levelWindow.classList.remove("is-open");
    resetSelection();
});
