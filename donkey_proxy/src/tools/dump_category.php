<?PHP
$group_table = array(
	1=>"chongwu", // pet
	2=>"zp",
	3=>"zp",
	8=>"zp", // qjz
	4=>"fw", // 服务
	5=>"fw", // 黄页
	6=>"che",
	7=>"fang",
	9=>"fw", // 教育培训
	10=>"piaowu", // 票务
	11=>"zp",
	12=>"huodong", //活动
	13=>"jiaoyou", //技能
	14=>"wu", // 二手
	15=>"common", // 老医疗
	);


$link = mysqli_connect("10.3.255.21:3311","off_mymsc_r","JHAS129sioq1","management") or die("Error " . mysqli_error($link)); 

//consultation: 

$query = "SELECT category_id, url FROM category" or die("Error in the consult.." . mysqli_error($link)); 

//execute the query. 

$result = $link->query($query); 

//display information: 
$category_data = array();

while($row = mysqli_fetch_array($result)) { 
  #echo $row["category_id"] . $row['url'] . "<br>"; 
	$id = $row[0];
	$query = "SELECT category_id, url FROM category_major where parent_id = $id";
	$category_data[ $row[1]] = array("group" => $group_table[$id]);

	// major category
	$r1 = $link->query($query);
	$subcategory = array();
	while($row1 = mysqli_fetch_array($r1)) {
		#echo $row1[0];
		$mid = $row1[0];
		$category_data[$row1[1]] = array( "group" =>  $group_table[$id], "mcat" => $mid, "type"=>"" );

		$r2 = $link->query( "SELECT category_id, url FROM category_minor where parent_id = $mid");
		while($row2 = mysqli_fetch_array($r2)) {
			$category_data[$row2[1]] = array( "group" =>  $group_table[$id], "mcat" => $mid, "type"=>"minor" );
			// 获取minorcategory的tag
			$minor_id = $row2[0];
			$r3 = $link->query( "SELECT url FROM tag where minor_category = $minor_id");
			while($row3 = mysqli_fetch_array($r3)) {
				$category_data[$row3[0]] = array( "group"=> $group_table[$id], "mcat"=>$mid, "minor"=>$minor_id, "type"=>'tag' );
			}
		}

		// 获取majorcategory的tag
		$r2 = $link->query( "SELECT url FROM tag where major_category = $mid");
		while($row2 = mysqli_fetch_array($r2)) {
			$category_data[$row2[0]] = array( "group"=> $group_table[$id], "mcat"=>$mid, "type"=>'tag' );
		}
	}

} 

print_r(json_encode($category_data, JSON_PRETTY_PRINT));
#off_mymsc_r:JHAS129sioq1@tcp(10.3.255.21:3311)/management
