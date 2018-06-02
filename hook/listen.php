<?php

const JSON = 'application/json';
const FORM = 'application/x-www-form-urlencoded';

$signKey = getenv('TOKEN');
$signature = explode('=', $_SERVER['HTTP_X_HUB_SIGNATURE']);
$contentType = $_SERVER['CONTENT_TYPE'];

switch($contentType) {
    case JSON:
        $requestBody = file_get_contents('php://input');
        break;
    case FORM:
        $requestBody = $_POST['payload'];
        break;
    default:
        throw new Exception('GET PAYLOAD FAILD');
        die();
        break;
}

$algo = $signature[0];

$signCalc = hash_hmac($algo, $requestBody, $signKey);

if ($signCalc != $signature[1]) {
    throw new Exception('SIGN VERIFY FAILD');
    die();
}

exec('cd /article && git fetch --all && git reset --hard origin/master');
exit();
