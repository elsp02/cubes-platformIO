// loader_bauen.js - connection-driven loader for bauen.html.
//
// Unlike loader_page.js (index.html), this loader is not time-based:
// it stays visible until the websocket connection is established and
// comes BACK when the connection drops. That is why the loader is only
// hidden via display:none instead of being removed from the DOM.

const loader = document.getElementById("loader");
const page = document.getElementById("bauen");

export function showLoader() {
    loader.style.display = "";
    gsap.to(loader, { opacity: 1, duration: 0.3 });
    gsap.to(page, { opacity: 0, duration: 0.3 });
}

export function hideLoader() {
    gsap.timeline()
        .to(loader, {
            opacity: 0,
            duration: 0.6,
            ease: "power2.inOut",
            onComplete: () => {
                loader.style.display = "none";
            },
        })
        .to(page, { opacity: 1, duration: 0.6, ease: "power2.out" }, "<");
}
