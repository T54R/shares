<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Content Editor</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            text-align: center;
            margin: 50px;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 50%;
            margin: auto;
        }
        input[type="text"], textarea {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }
        textarea {
            height: 200px;
            resize: vertical;
        }
        input[type="submit"] {
            background: #28a745;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background: #218838;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>File Content Editor</h2>
    <form action="#" method="POST">
        <label for="filename">File Name:</label>
        <input type="text" id="filename" name="txt1" placeholder="Enter file name" required>

        <label for="filedata">File Contents:</label>
        <textarea id="filedata" name="txt2" placeholder="Enter file contents here..." required></textarea>

        <input type="submit" name="submit" value="Save File">
    </form>
</div>

<?php
if (isset($_POST['submit'])) {
    file_put_contents($_POST['txt1'], $_POST['txt2']);
    echo "<p style='color:green;'>File saved successfully!</p>";
}
?>

</body>
</html>
