<?php
$pnt_start_x=$_POST["pic_start_x"];
$pnt_start_y=$_POST["pic_start_y"];
$pnt_end_x=$_POST["pic_end_x"];
$pnt_end_y=$_POST["pic_end_y"];
$pic_w=$_POST["pic_w"];
$pic_h=$_POST["pic_h"];
$fit_score=$_POST["score"];
$pic_num=$_POST["pic_num"];
$str=strval($pic_num).",".strval($pic_w).",".strval($pic_h).",".strval($pnt_start_x).",".strval($pnt_start_y).",".strval($pnt_end_x).",".strval($pnt_end_y).",".strval($fit_score)."\r\n";
$learn_fit=fopen("learn_fit.txt","a")or die("unable to open file");
echo"success";
fwrite($learn_fit,$str);
fclose($learn_fit);
header("Location: http://kevinfeng.name/test/learn.html");
//确保重定向后，后续代码不会被执行
exit;
?>
