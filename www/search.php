<html>
<head>
<link rel="stylesheet" type="text/css" href="../style.css"/>
</head>
<body>

<?php
$query = $_GET['q'];
print("<h1><a href='./'>up</a></h1>");

print "<h2>Szukaj</h2>";
print("<p><form action='search.php'><input type='text' name='q' value='" . $query . "'>&nbsp;<input type='submit' value='szukaj'></form></p>");

print "<h2>Ostatnie 20 znalezionych audycji</h2>";
$dirs = scandir('.');
rsort($dirs);

$limit_left = 20;
foreach ($dirs as $d) {
	if (!preg_match('/^20.?.?-.?.?-.?.?$/', $d))
		continue;
	$files = scandir($d);
	rsort($files);

	foreach ($files as $f) {
		if (!$limit_left)
			break 2;
		if (stristr($f, $query)!==false && substr($f, -4) == '.mp3' && substr($f, -10) != '.noads.mp3') {
			$limit_left --;
			print("<p style='font-size: 1.3em'>");
			print("<a href='./player.php?file=$d/" . urlencode($f) . "'>$f</a>");
			if (file_exists("$d/$f.noads.mp3")) {
				print(" &nbsp; &nbsp; <a href='./player.php?file=$d/" . urlencode($f) . ".noads.mp3'>noads</a>");
			}
			if (file_exists("$d/$f.noads.mp3.m4a")) {
				print(" &nbsp; &nbsp; <a href='./player.php?file=$d/" . urlencode($f) . ".noads.mp3.m4a'>aac</a>");
			}
			print("</p>");
		}
	}
}
?>

</body>
</html>

