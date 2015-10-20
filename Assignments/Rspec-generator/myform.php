<html>
<body>
The number of servers is: <?php echo $_POST['numservers']; ?><br />
The number of clients is: <?php echo $_POST['numclients']; ?><br />
<br />
Do you like this website? <?php echo $_POST['likeit']; ?><br />
<br />
Comments:<br />
<?php echo $_POST['comments']; ?>
<?php
$numOfServers = $_POST['numservers'];
$numOfClients = $_POST['numclients'];
$total = $numOfServers + $numOfClients;
$sourcename = "Source1";
$source = "property.resource1";
$target_serverpath = "uploads/server/";
$server_new_file_name = uniqid(). basename( $_FILES['uploadedserverfile']['name']);
$target_serverpath = $target_serverpath . $server_new_file_name;
if(move_uploaded_file($_FILES['uploadedserverfile']['tmp_name'], $target_serverpath)) {
    echo "The server file ".  basename( $_FILES['uploadedserverfile']['name']).
    " has been uploaded"."<br>";
} else{
    echo "There was an error uploading the server file, please try again!";
}
$target_clientpath = "uploads/client/";
$client_new_file_name = uniqid(). basename( $_FILES['uploadedclientfile']['name']);
$target_clientpath = $target_clientpath . $client_new_file_name;
if(move_uploaded_file($_FILES['uploadedclientfile']['tmp_name'], $target_clientpath)) {
    echo "The client file ".  basename( $_FILES['uploadedclientfile']['name']).
    " has been uploaded\n"."<br>";
} else{
    echo "There was an error uploading the client file, please try again!\n";
}
#$target_serverpath = "http://emmy10.casa.umass.edu/" + $target_serverpath
#$target_clientpath = "http://emmy10.casa.umass.edu/" + $target_clientpath
$tmp = exec("python test.py $numOfServers $numOfClients $target_serverpath $server_new_file_name");
 $tmp1 = exec("python test1.py $numOfServers $numOfClients $target_serverpath $server_new_file_name $target_clientpath $client_new_file_name");
 $tmp2 = exec("python rspecgenerator.py $numOfServers $numOfClients $target_serverpath $server_new_file_name $target_clientpath $client_new_file_name");
 $tmp3 = exec("python oedl.py $sourcename $source $total");
 echo $tmp2;
 echo $tmp3;
#$sample = exec("python test.py")
?>
</body>
</html>
