// progress_bar.js
// - fills #progress-bar-fill (inside #progress-bar on bauen.html) to show
//   how much of the target construction is already built correctly

const fill = document.getElementById("progress-bar-fill");

// updateProgress
// - sets the bar width to correctCount/totalCount as a percentage
export function updateProgress(correctCount, totalCount) {
    const percent = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
    fill.style.width = `${percent}%`;
}
