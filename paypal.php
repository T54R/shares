<?php

// Set up PayPal API credentials
$client_id = 'AaF_tOmiLlvXGGNrQVFS6VKyPdH4cF4BHqabFPTGMTVmquy37LmSuJvm1vkC5aFWlxDO9AoFNZRVNkyV';
$client_secret = 'ECGKQYFbGVLnqELfI_7fBdJXEVhUVn_PI-YptqRKTxh5w7jQxpGtevadTQLDvsHrl0EPkCs6Wprk0FWu';

// Set up PayPal environment
$base_url = 'https://api.paypal.com';
// For sandbox testing, use the following line instead:
// $base_url = 'https://api.sandbox.paypal.com';

// Set the payment amount (replace this with your logic to get the amount from a parameter)
$amount = '10.00';
$currency = 'USD';

// Create an access token
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $base_url.'/v1/oauth2/token');
curl_setopt($ch, CURLOPT_RETURNTRANSFERc, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_USERPWD, $client_id . ':' . $client_secret);
curl_setopt($ch, CURLOPT_POSTFIELDS, 'grant_type=client_credentials');
$result = curl_exec($ch);
curl_close($ch);

$response = json_decode($result, true);

if (isset($response['access_token'])) {
    // Create an order
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $base_url.'/v2/checkout/orders');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Authorization: Bearer ' . $response['access_token']
    ));
    $body = json_encode([
        'intent' => 'CAPTURE',
        'purchase_units' => [
            [
                'amount' => [
                    'currency_code' => $currency,
                    'value' => $amount
                ]
            ]
        ]
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    $result = curl_exec($ch);
    curl_close($ch);

    $response = json_decode($result, true);

    if (isset($response['id'])) {
        // Redirect the user to the approval link to complete the payment
        $approvalLink = '';
        foreach ($response['links'] as $link) {
            if ($link['rel'] === 'approve') {
                $approvalLink = $link['href'];
                break;
            }
        }

        if (!empty($approvalLink)) {
            header("Location: $approvalLink");
            exit();
        } else {
            echo 'Unable to find approval link.';
        }
    } else {
        echo 'Error creating PayPal order.';
    }
} else {
    echo 'Error getting PayPal access token.';
}
