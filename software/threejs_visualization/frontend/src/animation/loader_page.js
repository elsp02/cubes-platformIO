// loader_page.js - loading screen for index.html ( dashboard)

const MIN_LOADER_TIME = 3000; // ms


const loader = document.getElementById("loader");
const page = document.getElementById("dashboard");
const loaderGif = document.getElementById("loader-gif");


const startTime = performance.now();

// Lock scrolling as long as loader is visible
document.documentElement.style.overflow = "hidden";
document.body.style.overflow = "hidden";

//smooth fade in of GIF
if (typeof gsap !== "undefined"){
    gsap.set(loader, {opacity:1}); //loader container without fade in 
    gsap.fromTo(loaderGif, {opacity:0}, {opacity: 1, duration: 1, ease: "power2.out"}); //gif fade in within 1 sec 
}

// wait for window.load, then hide once MIN_LOADER_TIME has elapsed in total
window.addEventListener("load", ()=>{
    const elapsed = performance.now() -startTime;
    const remaining = Math.max(0, MIN_LOADER_TIME-elapsed);

    //call function hideLoader
    setTimeout(() => {
    hideLoader();
  }, remaining);
})

// hideLoader
// - fades the loader out and the dashboard in, then removes the loader from the DOM
function hideLoader (){
    //allow scrolling again
    document.documentElement.style.overflow = "";
    document.body.style.overflow = "";

  const i = gsap.timeline({
    onComplete: () => {
      loader.remove();
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