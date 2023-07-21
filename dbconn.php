<?php

 
$servername = "116.203.92.178:3306";
$username = "otuser";
$password = "r00t-p@ssw0rd@2019";
$dbname = "option_travel_website";


$sSQL= 'SET CHARACTER SET utf8'; 

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);


mysqli_query($conn, "SET CHARSET utf8;");   
mysqli_query($conn, "SET NAMES utf8;"); 


// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
echo 'Error' ;
}
$db= mysqli_select_db($conn,$dbname) or die("Couldn't select my database");

/*header('Location: https://optiontravel.com.eg/img/uploads/carrental/packages/p.php?paymenttoken=H96HFnpEmyWj4tCF1u36SPX3ERvUQnyu');*/
  
?>
