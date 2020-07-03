<html>
<head>
<script src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.3.1.min.js"></script>
</head>
<body>

<?php
$f = $_GET['file'];
print("<p style='font-size: x-large'>Play: $f</p>");
print("<p style='font-size: x-large'><a href='$f' type='application/octet-stream'>Download</a></p>");

if (file_exists("$f.png")) {
print("<audio id='a' autoplay style='width: 100%' controls ontimeupdate='updatePos(this)'><source src='$f' type='audio/mp3'></audio>");
print("<img id='s' style='width: 100%; height: 278px;' src='$f.png' />");
print("<canvas id='c' style='width: 100%; height: 278px; margin-top: -278px;' width='1944' height='278' onclick='chartClick(this, event)'></canvas>");
} else {
print("<audio id='a' autoplay style='width: 100%' controls ontimeupdate='updateTimestamp(this)'><source src='$f' type='audio/mp3'></audio>");
}

$p = substr($f, 22, 4);
print("<p id='time' data-start='$p'></p>");

if (file_exists("$f.markers.txt")) {
  $lines=file("$f.markers.txt");
  sort($lines);
  foreach ($lines as $line) {
    preg_match('/(.*) ([0-9]*)m([0-9.]*)s (.*)/', $line, $m);
    print("<a href='javascript:setPos(" . ltrim($m[1], '0') . ")'>$line</a><br/>");
  }
}

?>

<script>
function updateTimestamp(event) {
  var pos = event.currentTime;
  var v = parseInt($('#time').data('start'));
  var start = Math.floor(v/100)*60 + v % 100;
  var time = start * 60 + pos + 20;
  var h = Math.floor(time / 3600) % 24;
  var m = Math.floor(time / 60) % 60;
  var str = 'Godzina: ' + (h<10 ? '0' : '') + h + ':' + (m<10 ? '0' : '') + m;
  $('#time').text(str);
}

function updatePos(event) {
  var c = document.getElementById("c");
  var ctx = c.getContext("2d");
  ctx.clearRect(0, 0, c.width, c.height);
  var pos = event.currentTime;
  ctx.fillStyle = "#00ffff";
  ctx.fillRect(pos/2+57, 32, 2, 198);
}

function setPos(pos) {
  document.getElementById("a").currentTime=pos;
}

function chartClick(a,e) {
  var s = document.getElementById("s");
  var pos=(e.layerX/s.width*a.width - 57) * 2;

  document.getElementById("a").currentTime=pos;
}

</script>
</body>
</html>

