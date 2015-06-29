<?php
/*
	"Well well well, what do we have here. "
	
	This is a small script to do the converting for us, it will accept the token and the url encoded link
	then convert and print out a div with id "output" link for access by our AHK scripts
	UPLOAD THIS TO A PHP SERVER AND RECORD THE URL
*/

if (isset($_GET['url']) && isset($_GET['token']) && isurl($_GET['url']) && $_GET['token'] != ""){

	$access_token = $_GET['token'];
	$long_url = $_GET['url'];
	$shortened_url = bitly_url_shorten($long_url, $access_token);

}

//print out the url or failed in a div for application access
$out = (isset($shortened_url)?$shortened_url:"failed");
echo "<div id='output'>".$out."</div>";
	

function isurl($link){
	return filter_var(urldecode($link), FILTER_VALIDATE_URL);
}
	
function bitly_url_shorten($long_url, $access_token){

  $url = 'https://api-ssl.bitly.com/v3/shorten?access_token='.$access_token.'&longUrl='.urlencode($long_url);
  try {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_TIMEOUT, 4);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    $output = json_decode(curl_exec($ch));
  } catch (Exception $e) {
  }
  if(isset($output)){return $output->data->url;}
}

?>