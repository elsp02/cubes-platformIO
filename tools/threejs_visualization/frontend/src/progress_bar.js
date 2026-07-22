// progress_bar.js - fills the #statusanzeige bar on bauen.html to show
// how much of the target construction is already built correctly.

const fill = document.getElementById("progress-bar-fill");

export function updateProgress(correctCount, totalCount) {
    const percent = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
    fill.style.width = `${percent}%`;
}
