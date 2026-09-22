// split_toggle.js - lets the user click either half of the split view
// on build_reference.html to expand it (toggles .left-expanded on
// .split-tree-container; sizes/transition live in style.css)


const container = document.querySelector(".split-tree-container");
const leftPane = document.getElementById("comparison-tree");
const rightPane = document.getElementById("main-tree-compare");

if (container && leftPane && rightPane) {
    leftPane.addEventListener("click", () => {
        container.classList.add("left-expanded");
    });

    rightPane.addEventListener("click", () => {
        container.classList.remove("left-expanded");
    });
}
