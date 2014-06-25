#!/usr/bin/php
<?php
  $files = scandir('testresults');
  //var_dump($files);
  foreach($files as $file) {
    if (is_file('testresults/'.$file)) {
       print($file."\n");
       $contents = file_get_contents('testresults/'.$file);
       $matches = array();
       preg_match_all('/[0-9.]+(?=user)/',$contents,$matches);
       $mean = 0;
       $stddev = 0;
       $matches = $matches[0];
       foreach ($matches as $match) {
         //print($match);
         $value = (float)($match);
         $mean += $value;
         print($value.' ');
       }
       $mean /= count($matches);
       foreach ($matches as $match) {
         //print($match);
         $value = (float)($match);
         $stddev += pow($value-$mean,2);
         print($value.' ');
       }
       $stddev = sqrt($stddev/(count($matches)-1));
       print($mean." ".$stddev."\n");
       //print(."\n");//.' '.stats_standard_deviation($matches)."\n");
       //var_dump($matches);

    }
    
  }
?>