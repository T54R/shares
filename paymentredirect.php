<?php

include 'dbconn.php';
$paymenttoken = $_GET['paymenttoken'];
$sql = "select  * from otnew_payments where  payment_id='$paymenttoken' ";
$result = mysqli_query ($conn,$sql);


if (mysqli_num_rows($result) > 0) {

    $row = mysqli_fetch_assoc($result) ; 




    $access_code = 'A898fKH6yg2PNRtjmqvV';
    $amount = $row['amount'] * 100;
    $command = 'PURCHASE';
    $currency = $row['currency'];
    $customer_email = $row['customer_email'];
    $language = 'en';
    $merchant_identifier = 'qWxAxHiw';
    $merchant_reference = $paymenttoken;
    $order_description = $row['order_description'];

    $return_url = 'http://optiontravel.com.eg/paymentredirectresult.php';

    if (strtotime($row['creationdate']) > strtotime('-14 day')) {


        $requestParamsBeforeSign = array(
            'access_code' => $access_code,
            'amount' => $amount,
            'command' => $command,
            'currency' => $currency,
            'customer_email' => $customer_email,
            'language' => $language,
            'merchant_identifier' => $merchant_identifier,
            'merchant_reference' => $merchant_reference,
            'order_description' => $order_description,
            'return_url' => $return_url
        );

        $tempStr = "";
        foreach ($requestParamsBeforeSign as $aa => $bb) {
            $tempStr = $tempStr . $aa . '=' . $bb;
        }

        $tempStr = 'A898fKH6y' . $tempStr . 'A898fKH6y';

//echo $tempStr;
        $hashedSign = hash('sha256', $tempStr);


        $requestParams = array(
            'access_code' => $access_code,
            'amount' => $amount,
            'command' => $command,
            'currency' => $currency,
            'customer_email' => $customer_email,
            'language' => $language,
            'merchant_identifier' => $merchant_identifier,
            'merchant_reference' => $merchant_reference,
            'order_description' => $order_description,
            'return_url' => $return_url,
            'signature' => $hashedSign
        );



        $redirectUrl = 'https://checkout.payfort.com/FortAPI/paymentPage';
        echo "<html xmlns='http://www.w3.org/1999/xhtml'>\n<head></head>\n<body>\n";
        echo "<form action='$redirectUrl' method='post' name='frm'>\n";
        foreach ($requestParams as $a => $b) {
            echo "\t<input type='hidden' name='" . htmlentities($a) . "' value='" . htmlentities($b) . "'>\n";
        }
        echo "\t<script type='text/javascript'>\n";
        echo "\t\tdocument.frm.submit();\n";
        echo "\t</script>\n";
        echo "</form>\n</body>\n</html>";
    } else {
        header('Location: paymentredirectresult.php?errormsg=Payment link is expired');
        exit;
    }
} else {
    header('Location: paymentredirectresult.php?errormsg=Payment token not exist');
    exit;
}
?>
