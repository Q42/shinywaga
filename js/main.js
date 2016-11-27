EasingFunctions = {
  // no easing, no acceleration
  linear: function (t) { return t },
  // accelerating from zero velocity
  easeInQuad: function (t) { return t*t },
  // decelerating to zero velocity
  easeOutQuad: function (t) { return t*(2-t) },
  // acceleration until halfway, then deceleration
  easeInOutQuad: function (t) { return t<.5 ? 2*t*t : -1+(4-2*t)*t },
  // accelerating from zero velocity
  easeInCubic: function (t) { return t*t*t },
  // decelerating to zero velocity
  easeOutCubic: function (t) { return (--t)*t*t+1 },
  // acceleration until halfway, then deceleration
  easeInOutCubic: function (t) { return t<.5 ? 4*t*t*t : (t-1)*(2*t-2)*(2*t-2)+1 },
  // accelerating from zero velocity
  easeInQuart: function (t) { return t*t*t*t },
  // decelerating to zero velocity
  easeOutQuart: function (t) { return 1-(--t)*t*t*t },
  // acceleration until halfway, then deceleration
  easeInOutQuart: function (t) { return t<.5 ? 8*t*t*t*t : 1-8*(--t)*t*t*t },
  // accelerating from zero velocity
  easeInQuint: function (t) { return t*t*t*t*t },
  // decelerating to zero velocity
  easeOutQuint: function (t) { return 1+(--t)*t*t*t*t },
  // acceleration until halfway, then deceleration
  easeInOutQuint: function (t) { return t<.5 ? 16*t*t*t*t*t : 1+16*(--t)*t*t*t*t }
}

var time = 0;
let _fps = 30;

function animateWithFps(fps, fn) {
  var previous = 0;
  let interval = 1000 / fps;

  function loop() {
    var cur = (new Date).getTime();
    let diff = cur - previous;
    if(diff > interval) {
      fn();
      previous = cur;
    }

    requestAnimationFrame(loop);
  }

  loop();
}

function animate(duration, fn) {
  let startTime = (new Date).getTime();

  animateWithFps(_fps, () => {
    let curTime = (new Date).getTime();

    let diff = curTime - startTime;
    if(diff <= duration) {
      fn(diff/duration);
    }
  });
}

Animations = {
  linear: (duration, fn) => {
    animate(duration, (perc) => {
      fn(perc);
    });
  },
  easeInOutQuint: (duration, fn) => {
    animate(duration, (perc) => {
      fn(EasingFunctions.easeInOutQuint(perc));
    });
  }
}

function linear() {
  const playButton = document.getElementsByClassName('play-button')[index];
  playButton.classList.add('active');
  const body = document.getElementsByTagName('body')[0];
  body.classList.add('active');

  vid.load();
  vid.play();
}

function animateWithEasing() {
  const playButton = document.getElementsByClassName('play-button')[1];
  playButton.classList.add('active');
  const body = document.getElementsByTagName('body')[0];
  body.classList.add('active');


  Animations.easeInOutQuint(5000, (percentage) => {
    vid.currentTime = percentage * time;
  });
}

function preloadVideo(url) {
  console.log('Preloading', url);

  var req = new XMLHttpRequest();
  req.open('GET', url, true);
  req.responseType = 'blob';

  req.onload = function() {
   if (this.status === 200) {
    var videoBlob = this.response;
    var vidSrc = 'https://s3-eu-west-1.amazonaws.com/shinywagavideos/1480179553.mp4';
    vid.src = vidSrc;

    // Assume "video" is the video node
    var i = setInterval(function() {
      if(vid.readyState > 0) {
        time = vid.duration;
        clearInterval(i);
      }
    }, 200);
   }
  }

  req.send();
}

var vid, vid;

window.onload = () => {
  vid = document.getElementById('v0');
  vid.onended = onEnd
}

function onEnd() {
  const body = document.getElementsByTagName('body')[0];
  body.classList.remove('active');
}

// Initialize Firebase
var config = {
  apiKey: "AIzaSyBGFqoeaz2F6AT-RQAx9_eEH_0XgncOtzI",
  authDomain: "shinywaga.firebaseapp.com",
  databaseURL: "https://shinywaga.firebaseio.com",
  storageBucket: "shinywaga.appspot.com",
  messagingSenderId: "70833487694"
};
firebase.initializeApp(config);
