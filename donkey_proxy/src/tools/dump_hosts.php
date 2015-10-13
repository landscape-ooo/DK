<?PHP

$link = mysqli_connect("10.3.255.21:3311","off_mymsc_r","JHAS129sioq1","management") or die("Error " . mysqli_error($link)); 

//consultation: 

$query = "SELECT domain FROM city" or die("Error in the consult.." . mysqli_error($link)); 

//execute the query. 

$result = $link->query($query); 

//display information: 
$citys = array();

while($row = mysqli_fetch_array($result)) { 
	$citys[] = $row[0];
}

print_r( json_encode($citys));