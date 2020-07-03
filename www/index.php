<html>
<head>
<link rel="stylesheet" type="text/css" href="style.css"/>
</head>
<body>

<?php
date_default_timezone_set('Europe/Warsaw');
function start20($s) { return strstr($s, '20'); }
$dirs = array_filter(scandir('.'), 'start20');
rsort($dirs);

print "<h2>Na żywo</h2>";
if ($_SERVER['REQUEST_URI'] == '/weszlo/')
	print('<p>Live:</p> <audio controls="" name="media"><source src="https://radio.weszlo.fm/s7d70a7895/listen" type="audio/mpeg"></audio>');
if ($_SERVER['REQUEST_URI'] == '/trojka/')
	print('<p>Live:</p> <audio controls="" name="media"><source src="http://stream3.polskieradio.pl:8904/" type="audio/mpeg"></audio>');

if (file_exists("NOW.mp3")) {
	$target = readlink('NOW.mp3');
	$stime = date("Hi", filemtime('feed.xml'));
	$etime = date("Hi", filemtime($target));
	$label = "$stime-$etime ".end(preg_split('|[/]|', $target));
	print("<p>Aktualna audycja: <a href='player.php?file=NOW.mp3'>$label</a></p>");
}


print "<h2>Szukaj</h2>";
print("<p><form action='search.php'><input type='text' name='q'>&nbsp;<input type='submit' value='szukaj'></form></p>");

print "<h2>Ostatnie 10 audycji</h2>";
print "<table><thead><th>Tytuł</th><th></th><th></th></thead>";
print "<tbody>";

$count = 0;
foreach ($dirs as $d) {
	$files = scandir($d);
	rsort($files);
	

	foreach ($files as $f)
	if (substr($f, -4) == '.mp3' && substr($f, -10) != '.noads.mp3') {
		if ($count++ > 10) break 2;
		print("<tr style='font-size: 1.3em'><td>");
		print("$f");
		print "</td><td>";
		print("<a href='player.php?file=$d/" . urlencode($f) . "'>play</a>");
		print "</td><td>";
		if (file_exists("$d/$f.noads.mp3")) {
			print(" &nbsp; &nbsp; <a href='player.php?file=$d/" . urlencode($f) . ".noads.mp3'>noads</a>");
		}
		print "</td><td>";
		if (file_exists("$d/$f.noads.mp3.m4a")) {
			print(" &nbsp; &nbsp; <a href='player.php?file=$d/" . urlencode($f) . ".noads.mp3.m4a'>aac</a>");
		}
		print("</td></tr>");
	}
}
print "</tbody></table>";

print "<h2>Ostatnie 7 dni</h2>";
print "<table><tbody>";
$last7dirs = array_slice($dirs, 0, 7);
foreach ($last7dirs as $d) {
	print("<tr style='font-size: 1.3em'><td><a href='$d'>$d</a></td></tr>");
}
print "</tbody></table>";

print "<h2>Feedy podcastów</h2>";
if (file_exists('feed.aac.xml'))
  print ("<a href='feed.aac.xml'>Feed AAC 128k</a><br/>");
if (file_exists('feed.noads.xml'))
  print ("<a href='feed.noads.xml'>Feed bez reklam</a><br/>");

?>

<a href='feed.xml'>Feed normalny</a>

<h2>Kontakt</h2>
Kontakt przez wypok.pl: <a href='https://www.wykop.pl/wiadomosc-prywatna/konwersacja/sceptyk-/'>@sceptyk-</a>
</body>
</html>


