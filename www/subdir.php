<html>
<head>
<link rel="stylesheet" type="text/css" href="../style.css"/>
</head>
<body>

<?php
$dir = basename(getcwd());
print("<h1><a href='../'>up</a></h1>");
$files = scandir('.');
rsort($files);
foreach ($files as $f)
if (substr($f, -4) == '.mp3' && substr($f, -10) != '.noads.mp3') {
	print("<p style='font-size: 1.3em'>");
	print("<a href='../player.php?file=$dir/" . urlencode($f) . "'>$f</a>");
	if (file_exists("$f.noads.mp3")) {
		print(" &nbsp; &nbsp; <a href='../player.php?file=$dir/" . urlencode($f) . ".noads.mp3'>noads</a>");
	}
	if (file_exists("$f.noads.mp3.m4a")) {
		print(" &nbsp; &nbsp; <a href='../player.php?file=$dir/" . urlencode($f) . ".noads.mp3.m4a'>aac</a>");
	}
	print("</p>");
}
?>

</body>
</html>

