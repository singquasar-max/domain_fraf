<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A version of you the world has to see</title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;1,300;1,500&family=Bebas+Neue&display=swap" rel="stylesheet">
<style>
  :root{
    --ink:#05070b; --steel:#8fa3b8; --teal:#1f6f78; --amber:#ffb15c; --text:#dfe6ee;
  }
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{height:100%;background:var(--ink);color:var(--text);overflow:hidden}
  body{font-family:"Cormorant Garamond",Georgia,serif}

  /* light leaks */
  .glow{position:fixed;inset:-20%;pointer-events:none;
    background:
      radial-gradient(40% 35% at 15% 20%, rgba(31,111,120,.45), transparent 70%),
      radial-gradient(35% 30% at 85% 80%, rgba(255,150,60,.28), transparent 70%);
    animation:drift 18s ease-in-out infinite alternate}
  @keyframes drift{to{transform:translate(4%,3%) scale(1.1)}}

  /* film grain */
  .grain{position:fixed;inset:-50%;pointer-events:none;opacity:.16;mix-blend-mode:overlay;
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
    animation:grain .6s steps(4) infinite}
  @keyframes grain{
    0%{transform:translate(0,0)}25%{transform:translate(-4%,3%)}
    50%{transform:translate(3%,-5%)}75%{transform:translate(-2%,4%)}100%{transform:translate(0,0)}}

  .vignette{position:fixed;inset:0;pointer-events:none;
    background:radial-gradient(ellipse at center, transparent 45%, rgba(0,0,0,.85) 100%)}

  /* letterbox bars */
  .bar{position:fixed;left:0;width:100%;height:11vh;background:#000;z-index:5;
    transition:height 2.2s cubic-bezier(.2,.7,.2,1)}
  .bar.top{top:0}.bar.bottom{bottom:0}
  body.loaded .bar{height:8vh}

  /* stage */
  .stage{position:relative;height:100%;display:flex;align-items:center;justify-content:center;
    padding:12vh 7vw;animation:push 40s linear forwards}
  @keyframes push{from{transform:scale(1)}to{transform:scale(1.06)}}
  .quote{max-width:46rem;width:100%}

  .lead{font-style:italic;font-weight:300;font-size:clamp(1.3rem,3.2vw,2rem);
    color:var(--steel);margin-bottom:clamp(1rem,3vh,2rem);letter-spacing:.02em}

  .line{font-style:italic;font-weight:300;font-size:clamp(1.05rem,2.4vw,1.55rem);
    line-height:1.5;padding:.28em 0 .28em 1.1rem;border-left:1px solid rgba(143,163,184,.25)}

  .lead,.line,.final{opacity:0;filter:blur(14px);transform:translateY(8px);
    transition:opacity 1.6s ease,filter 1.6s ease,transform 1.6s ease}
  .show{opacity:1!important;filter:blur(0)!important;transform:none!important}
  .line.show{color:var(--text)}
  .line.past{opacity:.5!important}

  .final{margin-top:clamp(1.5rem,5vh,3rem);font-family:"Bebas Neue",Impact,sans-serif;
    font-size:clamp(2.2rem,7.5vw,5rem);line-height:1;letter-spacing:.04em;
    background:linear-gradient(100deg,#fff 20%,var(--amber) 60%,#fff 100%);background-size:200% 100%;
    -webkit-background-clip:text;background-clip:text;color:transparent;
    text-shadow:0 0 60px rgba(255,177,92,.35)}
  .final.show{animation:shine 6s ease-in-out 1.6s infinite alternate}
  @keyframes shine{to{background-position:-100% 0}}

  button{position:fixed;right:1.2rem;bottom:calc(8vh + .8rem);z-index:10;background:none;
    border:1px solid rgba(143,163,184,.35);color:var(--steel);padding:.4rem .9rem;
    font:inherit;font-size:.95rem;border-radius:2px;cursor:pointer;opacity:0;transition:opacity 1s,color .2s,border-color .2s}
  button.ready{opacity:.8}
  button:hover,button:focus-visible{color:#fff;border-color:#fff;outline:none}

  @media (prefers-reduced-motion:reduce){
    .glow,.grain,.stage,.final.show{animation:none}
    .lead,.line,.final{transition:none;filter:none;transform:none}
  }
</style>
</head>
<body>
  <div class="glow"></div>
  <div class="bar top"></div><div class="bar bottom"></div>

  <main class="stage">
    <blockquote class="quote" id="quote">
      <p class="lead">How life could be boring when:</p>
      <p class="line">you have a career to build</p>
      <p class="line">a body to sculpt and strengthen</p>
      <p class="line">endless hobbies to explore and master</p>
      <p class="line">books that can reshape how you think</p>
      <p class="line">limits that are meant to be tested</p>
      <p class="line">fears that are waiting to be conquered</p>
      <p class="final">A version of you that this world has to see.</p>
    </blockquote>
  </main>

  <div class="vignette"></div>
  <div class="grain"></div>
  <button id="replay" aria-label="Replay">Replay</button>

<script>
(function(){
  var items = Array.prototype.slice.call(document.querySelectorAll('.lead,.line,.final'));
  var btn = document.getElementById('replay');
  var timers = [];

  function play(){
    timers.forEach(clearTimeout); timers = [];
    btn.classList.remove('ready');
    items.forEach(function(el){el.classList.remove('show','past')});
    document.body.classList.remove('loaded');
    void document.body.offsetWidth;
    document.body.classList.add('loaded');

    var t = 1200;
    items.forEach(function(el, i){
      timers.push(setTimeout(function(){
        el.classList.add('show');
        if(el.classList.contains('line')){
          var prev = items[i-1];
          if(prev && prev.classList.contains('line')) prev.classList.add('past');
        }
        if(el.classList.contains('final')){
          items.forEach(function(x){ if(x.classList.contains('line')) x.classList.add('past'); });
        }
      }, t));
      t += el.classList.contains('final') ? 0 : (i === 0 ? 1800 : 1500);
    });
    timers.push(setTimeout(function(){btn.classList.add('ready')}, t + 2500));
  }

  btn.addEventListener('click', play);
  window.addEventListener('load', play);
})();
</script>
</body>
</html>
