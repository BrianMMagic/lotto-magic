Set-Location "c:\Users\brian\Documents\lotto"

$lotto = Get-Content "lotto.html" -Encoding UTF8

# Lines 36-81 (0-indexed 35-80): <script> open + base64 data + coordinate constants + var ids
$scriptData = ($lotto[35..80] -join "`n") + "`n"
# Lines 97-193 (0-indexed 96-192): loadImg, digits2, generate functions + </script>
$functions = ($lotto[96..192] -join "`n") + "`n"

$calcB64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("Calculator\blank-calculator.png"))

$header = @'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>Calculator</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body { background: #000; height: 100dvh; overflow: hidden; display: flex; align-items: center; justify-content: center; }
#calc-wrap { position: relative; height: 100dvh; }
#calc-wrap > .bg { height: 100%; width: auto; display: block; }
#disp-overlay { position: absolute; top: 30.2%; height: 11.4%; left: 0; right: 0; display: flex; align-items: center; justify-content: flex-end; padding-right: 5%; overflow: hidden; }
#disp-text { color: #fff; font-family: -apple-system, 'Helvetica Neue', sans-serif; font-weight: 200; white-space: nowrap; line-height: 1; }
.hit { position: absolute; background: transparent; border: none; border-radius: 50%; width: 20.4%; height: 9.4%; transform: translate(-50%, -50%); cursor: pointer; -webkit-tap-highlight-color: transparent; -webkit-appearance: none; outline: none; touch-action: manipulation; font-size: 0; }
#canvas-wrap { display: none; background: #000; width: 100%; text-align: center; padding: 16px; }
#canvas-wrap canvas { display: none; max-width: 100%; height: auto; border-radius: 8px; cursor: pointer; }
#hint { display: none; font-size: 0.85em; color: #aaa; margin-top: 8px; font-family: -apple-system, sans-serif; }
#error { display: none; }
</style>
</head>
<body>
<div id="calc-wrap">
  <img class="bg" src="data:image/png;base64,CALC_B64_HERE">
  <div id="disp-overlay"><span id="disp-text">0</span></div>
  <button class="hit" style="left:13.4%;top:46.2%" data-key="back"></button>
  <button class="hit" id="btn-c" style="left:37.8%;top:46.2%" data-key="c"></button>
  <button class="hit" style="left:62.2%;top:46.2%" data-key="pct"></button>
  <button class="hit" style="left:86.7%;top:46.2%" data-key="div"></button>
  <button class="hit" style="left:13.4%;top:57.4%" data-key="7"></button>
  <button class="hit" style="left:37.8%;top:57.4%" data-key="8"></button>
  <button class="hit" style="left:62.2%;top:57.4%" data-key="9"></button>
  <button class="hit" style="left:86.7%;top:57.4%" data-key="mul"></button>
  <button class="hit" style="left:13.4%;top:68.7%" data-key="4"></button>
  <button class="hit" style="left:37.8%;top:68.7%" data-key="5"></button>
  <button class="hit" style="left:62.2%;top:68.7%" data-key="6"></button>
  <button class="hit" style="left:86.7%;top:68.7%" data-key="sub"></button>
  <button class="hit" style="left:13.4%;top:80.0%" data-key="1"></button>
  <button class="hit" style="left:37.8%;top:80.0%" data-key="2"></button>
  <button class="hit" style="left:62.2%;top:80.0%" data-key="3"></button>
  <button class="hit" style="left:86.7%;top:80.0%" data-key="add"></button>
  <button class="hit" style="left:13.4%;top:91.2%" data-key="pm"></button>
  <button class="hit" style="left:37.8%;top:91.2%" data-key="0"></button>
  <button class="hit" id="btn-dot" style="left:62.2%;top:91.2%" data-key="dot"></button>
  <button class="hit" style="left:86.7%;top:91.2%" data-key="eq"></button>
</div>
<input type="number" id="b1" style="display:none">
<input type="number" id="b2" style="display:none">
<input type="number" id="b3" style="display:none">
<input type="number" id="b4" style="display:none">
<input type="number" id="b5" style="display:none">
<input type="number" id="b6" style="display:none">
<input type="checkbox" id="dbg" style="display:none">
<div id="error"></div>
<div id="canvas-wrap"><canvas id="c" width="699" height="786"></canvas></div>
<div id="hint">Long-press image to save to Photos</div>
'@

$calcJS = @'
var slots = [];
var currentInput = '';
var accumulator = 0;
var dotTimer = null;

function dispUpdate(val) {
  var el = document.getElementById('disp-text');
  el.textContent = val;
  var wrap = document.getElementById('disp-overlay');
  var baseSize = wrap.offsetHeight * 0.78;
  el.style.fontSize = baseSize + 'px';
  while (el.scrollWidth > wrap.offsetWidth * 0.92 && baseSize > 14) {
    baseSize -= 2;
    el.style.fontSize = baseSize + 'px';
  }
}

function updateCBtn() {
  document.getElementById('btn-c').textContent = (slots.length === 0 && currentInput === '') ? 'AC' : 'C';
}

function calcReset() {
  slots = []; currentInput = ''; accumulator = 0;
  dispUpdate('0');
  document.getElementById('btn-c').textContent = 'AC';
}

function fmtNum(n) { return n.toLocaleString('en-US'); }

function handleKey(key) {
  if ('0123456789'.indexOf(key) !== -1) {
    if (currentInput.length >= 2) return;
    currentInput += key;
    dispUpdate(currentInput);
    updateCBtn();
    return;
  }
  if (key === 'back') {
    currentInput = currentInput.slice(0, -1);
    dispUpdate(currentInput || '0');
    updateCBtn();
    return;
  }
  if (key === 'add') {
    if (currentInput === '' || slots.length >= 5) return;
    var n = parseInt(currentInput, 10);
    if (isNaN(n)) return;
    slots.push(n);
    accumulator += n;
    currentInput = '';
    dispUpdate(fmtNum(accumulator));
    updateCBtn();
    return;
  }
  if (key === 'eq') {
    if (slots.length !== 5 || currentInput === '') return;
    var n = parseInt(currentInput, 10);
    if (isNaN(n)) return;
    slots.push(n);
    ids.forEach(function(id, i) { document.getElementById(id).value = slots[i]; });
    document.getElementById('calc-wrap').style.display = 'none';
    document.getElementById('canvas-wrap').style.display = 'block';
    generate();
    return;
  }
  if (key === 'c') {
    if (currentInput !== '') {
      currentInput = '';
      dispUpdate(accumulator > 0 ? fmtNum(accumulator) : '0');
    } else if (slots.length > 0) {
      var last = slots.pop();
      accumulator -= last;
      dispUpdate(slots.length > 0 ? fmtNum(accumulator) : '0');
    }
    updateCBtn();
    return;
  }
}

(function() {
  var dotEl = document.getElementById('btn-dot');
  document.querySelectorAll('.hit').forEach(function(btn) {
    if (btn === dotEl) return;
    btn.addEventListener('touchend', function(e) {
      e.preventDefault();
      handleKey(this.getAttribute('data-key'));
    });
    btn.addEventListener('click', function() {
      handleKey(this.getAttribute('data-key'));
    });
  });
  dotEl.addEventListener('touchstart', function() {
    dotTimer = setTimeout(function() { calcReset(); }, 500);
  });
  dotEl.addEventListener('touchend', function(e) {
    e.preventDefault();
    clearTimeout(dotTimer);
  });
  dotEl.addEventListener('mousedown', function() {
    dotTimer = setTimeout(function() { calcReset(); }, 500);
  });
  dotEl.addEventListener('mouseup', function() { clearTimeout(dotTimer); });
  document.getElementById('c').addEventListener('click', function() {
    document.getElementById('canvas-wrap').style.display = 'none';
    document.getElementById('hint').style.display = 'none';
    document.getElementById('calc-wrap').style.display = '';
    calcReset();
  });
  window.addEventListener('load', function() { dispUpdate('0'); });
})();

'@

$footer = @'
</body>
</html>
'@

$newContent = $header.Replace("CALC_B64_HERE", $calcB64) + $scriptData + $calcJS + $functions + $footer
[System.IO.File]::WriteAllText((Resolve-Path "lotto.html").Path, $newContent, [System.Text.Encoding]::UTF8)
Write-Output "Done. lotto.html updated successfully."
