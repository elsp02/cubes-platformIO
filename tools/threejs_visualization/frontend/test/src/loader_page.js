// page while connecting with server - dissapears when connected
// ???? what if connection breaks? - maybe text with reload window
const MIN_LOADER_TIME = 5000; // ms

//adress components
const loader = document.getElementById("loader-container");
const page = document.getElementById("main-container");
const loaderGif = document.getElementById("loader-gif");

//get start time (for e.g breaking connecting attempt)
const startTime = performance.now();

// Lock scrolling as long as loader is visible
document.documentElement.style.overflow = "hidden";
document.body.style.overflow = "hidden";

//smooth fade in of GIF
if (typeof gsap !== "undefined"){
    gsap.set(loader, {opacity:1}); //loader container without fade in 
    gsap.fromTo(loaderGif, {opacity:0}, {opacity: 1, duration: 1, ease: "power2.out"}); //gif fade in within 1 sec 
}

// condition when to remove loader window (currently time dependent)- change this to condition server connected
window.addEventListener("load", ()=>{
    const elapsed = performance.now() -startTime;
    const remaining = Math.max(0, MIN_LOADER_TIME-elapsed);

    //call function hideLoader
    setTimeout(() => {
    hideLoader();
  }, remaining);
})

function hideLoader (){
    //allow scrolling again
    document.documentElement.style.overflow = "";
    document.body.style.overflow = "";

  const i = gsap.timeline({
    onComplete: () => {
      loader.remove();

      // resync lenis
      // (je nachdem, wie ich Lenis initialisierst, heißt die Variable evtl. anders)
      if (window.lenis) {
        window.lenis.resize();
        window.lenis.scrollTo(window.lenis.scroll, { immediate: true }); // stabilisiert den State
      }

      // don´t need this because no scroll trigger
      if (typeof ScrollTrigger !== "undefined") {
        ScrollTrigger.refresh(true);
      }

      // auto fresh hook
      if (window.__AUTO_SHOW_REFRESH__) {
        window.__AUTO_SHOW_REFRESH__();
      }

      if (window.startStickerSpins) {
        window.startStickerSpins();
      }
    }
  });

  //when time is expired/connection is valid - loader dissappears and page appears 
  i.to(loader, {
    opacity: 0,
    duration: 0.6,
    ease: "power2.inOut"
  })
  .to(page, {
    opacity: 1,
    duration: 0.6,
    ease: "power2.out"
  })
}