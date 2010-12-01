<?

// !snow module for rb, written by Nathan Witmer, January 2005
// Code update Feb 2005
// Update for 2005/2006 season Oct 2005, fixed conditions formatting code

//die("currently being updated");
//$f=file_get_contents('http://une:10080/snow.php');
//if($_SERVER['REMOTE_ADDR']=='64.239.4.33') print("ahoy! snow be on the ground! yarr!");
//else print($f);
//if($dest != '#snow') print("ahoy! snow be on the ground! yarr!"); else print($f);
//print($f);

//echo "the ski season's over. go away."; exit;
//echo "have patience. all things in time."; exit;

$debug = $argc > 1;


if($debug) {
	error_reporting(E_ALL);
	// check for command-line args for cmd-line debugging
	if($argc > 1) {
		array_shift($argv);
		$args = implode(' ',$argv);
	}
}

function debugval($val) {
	global $debug;
	if($debug) print_r($val);
}

$resorts = array(
// name, url and mask must be defined. the rest are used as "variable variables" in the mask
// mask may be set to 'default', which is '$name $snow24/$snow48/$snow72/$base $conditions'
// if the name is 'conditions' then it will be formatted as such
// make sure that '<varname>idx' is set, that's the index for the preg_match
array(
	'name'=>'ABasin',
	//'url'=>'http://nathan.f3h.com/snow/abasin.html',
	'url'=>'http://arapahoebasin.com/?page=site/snow_report',
	'base'=>'@Midway Snow Depth:\s+(<[^>]*>\s+){2}\s+(\d+)@mis', 'baseidx'=>2,
	'snow24'=>'@Last 24 Hours:\s+(\d+(\.\d)?)@mis', 'snow24idx'=>1,
	'snow3day'=>'@Last 3 days:\s+(\d+(\.\d)?)@mis', 'snow3dayidx'=>1,
	'conditions'=>'@Conditions:\s+(<[^>]*>\s+){2}\s+(.*?)</font>@mis', 'conditionsidx'=>2,
	'mask'=>'$name $snow24/$snow3day/$base $conditions'
	),
array(
	'name'=>'Cu', 
	'url'=>'http://coppercolorado.com/mountain/snowreport/index.htm', 
	'base'=>'@Mid Mountain Base.*?<tr>\s+<td>(\d+)@mis', 'baseidx'=>1,
	'snow24'=>'@24 hrs.*?<tr>\s+<td>(\d+)@mis', 'snow24idx'=>1, 
	'snow48'=>'@48 hrs.*?<tr>\s+<td>\d+</td>\s+<td>(\d+)@mis', 'snow48idx'=>1, 
	'snow72'=>'@72 hrs.*?<tr>\s+(<td>\d+</td>\s+){2}<td>(\d+)@mis', 'snow72idx'=>2,
	'conditions'=>'@Surface Conditions.*?<tr>\s+<td>\d+</td>\s+<td>(.*?)<@mis', 'conditionsidx'=>1,
	'mask'=>'default',
	),
array( 'name'=>'WP', 
	'url'=>'http://www.skiwinterpark.com/mountain/snow_report/index.htm',
	'base'=>'@Mid-Mountain Depth([^>]*>){6}(\d*)@mis', 'baseidx'=>2,
	'snow24'=>'@24 hrs([^>]*>){10}(\d*(\.\d)?)@mis', 'snow24idx'=>2,
	'snow48'=>'@48 hrs([^>]*>){10}(\d*(\.\d)?)@mis', 'snow48idx'=>2,
	'snow72'=>'@72 hrs([^>]*>){10}(\d*(\.\d)?)@mis', 'snow72idx'=>2,
	'conditions'=>'@colspan="2">\s+Conditions([^>]*>){4}([^<]+)@mis', 'conditionsidx'=>2,
	'mask'=>'default',
//  'mask'=>'WP 16th',
	),
array(
	'name'=>'Loveland', 
	'url'=>'http://www.skiloveland.com/snowrep/snowrep.asp',
	'base'=>'@Snow Depth([^>]+>){6}\s*(\d+)@mis', 'baseidx'=>2,
	'snow24'=>'@24Hrs[^>]+>\s*(\d+)@mis', 'snow24idx'=>1,
	'snow48'=>'@48Hrs[^>]+>\s*(\d+)@mis', 'snow48idx'=>1,
	'snow72'=>'@72Hrs[^>]+>\s*(\d+)@mis', 'snow72idx'=>1,
	'conditions'=>'@Surface Conditions([^>]+>){6}\s*(.*?)<@mis', 'conditionsidx'=>2,
	'mask'=>'default',
	), 
array(
  'name'=>'Breck',
	'url'=>'http://breckenridge.snow.com/mtn.conditions.asp',
	'snow24'=>'@Total 24 hrs(.*?>){6}(\d+)"@mis', 'snow24idx'=>2,
	'snow48'=>'@Last 48 hrs(.*?>){6}(\d+)"@mis', 'snow48idx'=>2,
	'base'=>'@Mid Mountain\s+</td>(.*?>){7}(\d+)"@mis', 'baseidx'=>2,
	'conditions'=>'@Snow Conditions\s+</td>(.*?>){5}(.*?)</td>@mis', 'conditionsidx'=>2,
	'mask'=>'$name $snow24/$snow48/$base $conditions',
	),
array(
  'name'=>'Keystone',
	'url'=>'http://keystone.snow.com/report.asp',
  'snow24'=>'@Total 24 hrs(.*?>){6}(\d+)"@mis', 'snow24idx'=>2,
  'snow48'=>'@Last 48 hrs(.*?>){6}(\d+)"@mis', 'snow48idx'=>2,
  'base'=>'@Mid Mountain\s+</td>(.*?>){7}(\d+)"@mis', 'baseidx'=>2,
  'conditions'=>'@Snow Conditions\s+</td>(.*?>){5}(.*?)</td>@mis', 'conditionsidx'=>2,
  'mask'=>'$name $snow24/$snow48/$base $conditions',
  ),
array(
  'name'=>'Vail',
	'url'=>'http://vail.snow.com/mtn.report.asp',
	'base'=>'@Settled Base([^>]+>){14}(\d+)@mis', 'baseidx'=>2,
	'snow24'=>'@New 24-hour Snowfall([^>]+>){10}(\d+)@mis', 'snow24idx'=>2,
	'snow48'=>'@New 48-hour Snowfall([^>]+>){10}(\d+)@mis', 'snow48idx'=>2,
	'snow7day'=>'@Past 7-day Snowfall([^>]+>){10}(\d+)@mis', 'snow7dayidx'=>2,
//	'conditions'=>'@Conditions as of ([^>]+>){12}([^<]+)@mis', 'conditionsidx'=>2,
//	'mask'=>'$name $snow24/$snow48/$snow7day/$base $conditions',
	'mask'=>'$name $snow24/$snow48/$snow7day/$base',
  ),
array(
	'name'=>'Beaver Creek',
	'url'=>'http://beavercreek.snow.com/mtn.report.asp',
  'base'=>'@>\s+Mid Mountain([^>]+>){8}(\d+)@mis','baseidx'=>2,
	'snow24'=>'@Total 24 hrs([^>]+>){6}(\d+)@mis','snow24idx'=>2,
	'snow48'=>'@Total 48 hrs([^>]+>){6}(\d+)@mis','snow48idx'=>2,
	'conditions'=>'@>\s+Snow Conditions\s+<([^>]+>){6}([^<]+)@mis','conditionsidx'=>2,
  'mask'=>'$name $snow24/$snow48/$base $conditions',
  ),
array(
	'name'=>'Steamboat', 
	'url'=>'http://www.steamboat.com/xml/xml.aspx?feed=snow',
	'base'=>'@MidMountainBase.*?>(\d+)@mis', 'baseidx'=>1,
	'snow24'=>'@MidMountain24Hour.*?>(\d+)@mis', 'snow24idx'=>1,
	'snow48'=>'@MidMountain48Hour.*?>(\d+)@mis', 'snow48idx'=>1,
	'snow72'=>'@MidMountain72Hour.*?>(\d+)@mis', 'snow72idx'=>1,
	'conditions'=>'@Conditions.*?>(.*?)<@mis', 'conditionsidx'=>1,
	'mask'=>'default',
	//'mask'=>'Steamboat 24th',
	),
array(
  'name'=>'Aspen Highlands',
//  'url'=>'http://www.aspensnowmass.com/onmountain/reports/conditions.cfm?area=Aspen%20Highlands&bhfv=2&bhfx=8.0%20%20r22&bhdv=1&bhdx=10.1&bhsp=8275829',
  'url'=>'http://feeds.feedburner.com/snowreport',
  'base'=>'@Aspen Highlands([^>]+>){6}.*?depth:\s+(\d+)@mis','baseidx'=>2,
  'snow24'=>'@Aspen Highlands([^>]+>){6}.*?24 Hours:\s+(\d+)@mis','snow24idx'=>2,
  'snow48'=>'@Aspen Highlands([^>]+>){6}.*?48 Hours:\s+(\d+)@mis','snow48idx'=>2,
  'conditions'=>'@Aspen Highlands([^>]+>){6}.*?conditions:\s+([^<]+)@mis','conditionsidx'=>2,
  'mask'=>'$name $snow24/$snow48/$base $conditions',
  ),
array(
  'name'=>'Whistler', 
  'url'=>'http://www.whistlerblackcomb.com/weather/snowreport/index.htm',
	'base'=>'@Snowbase([^>]*>){24}(\d+)@mis','baseidx'=>2,
	'snownew'=>'@New<([^>]*>){24}(\d+)@mis', 'snownewidx'=>2,
	'snow24'=>'@24 Hours([^>]*>){24}(\d+)@mis', 'snow24idx'=>2,
	'snow48'=>'@48 Hours([^>]*>){24}(\d+)@mis', 'snow48idx'=>2,
//	'conditions'=>'@Conditions<([^>]*>){10}([^<]+)@mis', 'conditionsidx'=>2,
	'mask'=>'$name $snownew/$snow24/$snow48/$base',
  ),
array(
	'name'=>'Heavenly',
	'url'=>'http://www.skiheavenly.com/conditions/snow/',
	'base1'=>'@Current Base Depth([^>]+>){36}\s+(\d+)@mis', 'base1idx'=>2,
	'snow24'=>'@New Snow Past 24([^>]+>){36}\s+(\d+)@mis', 'snow24idx'=>2,
	'snow48'=>'@New Snow Past 48([^>]+>){36}\s+(\d+)@mis', 'snow48idx'=>2,
	'mask'=>'$name $snow24/$snow48/$base1',
	),
array(
	'name'=>'Mammoth',
	'url'=>'http://www.mammothmountain.com/ski_ride/',
	'newsnow'=>'@strong>New Snow([^>]+>){3}[^:]+:\s*(\d+)@mis', 'newsnowidx'=>2,
	'base'=>'@Base Depth([^>]+>){1}\s*(\d+(-\d+))@mis', 'baseidx'=>2,
	'mask'=>'$name $newsnow/$base\'',
//  'mask'=>'$name 23rd',
	),
array(
	'name'=>'Eldora',
	'url'=>'http://www.eldora.com/snowReport.cfm',
	'base'=>'@Base([^>]+>){2}(\d+(\.\d+)?)@mis', 'baseidx'=>2,
	'snow24'=>'@last\s+24 hours([^>]+>){3}(\d+(\.\d+)?)@mis', 'snow24idx'=>2,
	'snow48'=>'@last\s+48 hours([^>]+>){3}(\d+(\.\d+)?)@mis', 'snow48idx'=>2,
	'snow72'=>'@last\s+72 hours([^>]+>){3}(\d+(\.\d+)?)@mis', 'snow72idx'=>2,
	'conditions'=>'@Surface Conditions([^>]+>){2}([^<]+)@mis', 'conditionsidx'=>2,
	'mask'=>'$name $snow24/$snow48/$snow72/$base $conditions',
	),
);

$lookup= array(
	array('packed powder','PP'),
	array('packedpowder','PP'),
	array('powder','P'),
	array('man-made','MM'),
	array('man made','MM'),
	array('machine made','MM'),
	array('hard packed','HP'),
	array('trace','T'),
	array('springlike conditions','SP'),
	array('groomed','GR'),
	array('variable conditions','VC'),
	array('variable','V'),
	array(' day!',''),
);

function format_conditions($c) {
	global $lookup;
	foreach ($lookup as $l) {
		$search[]=$l[0];
		$replace[]=$l[1];
	}
	
	$c = strtolower(trim($c));
	debugval("conditions string: $c\n");
	$c = str_replace('poweder','powder',$c); // misspelling!
	$c = str_replace($search,$replace,$c);
	debugval("after initial search/replace: $c\n");
	//$c = preg_replace('/[^a-zA-Z\/,]/','',$c);
	$c = preg_replace('/\s+/','/',$c);
	debugval("after cutting out whitespace: $c\n");
	$c = str_replace(',','/',$c);
	$c = preg_replace('/\s+/','/',$c);
	// clean up any multi-slash messes
	$c = preg_replace('/\/+/','/',$c);
	$c = strtoupper($c);

	return $c;
}

$ch =  curl_init();
curl_setopt($ch, CURLOPT_FAILONERROR, TRUE); // won't return any error pages
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE); // return string
curl_setopt($ch, CURLOPT_USERAGENT, 'rbot'); // heh

$specific = isset($args)?strtolower($args):'';
if($specific) debugval("looking for $specific\n");

$comma=false;
$final='';

foreach($resorts as $resort) {

	if($specific && strtolower($resort['name']) != $specific) continue;

	curl_setopt($ch, CURLOPT_URL, $resort['url']);
	$report = curl_exec($ch);
	$err = curl_error($ch);
	if($err) print("error: $err\n");
	
	// now, using the magic of variable variables, process the report.
	$mask = $resort['mask']=='default'?'$name $snow24/$snow48/$snow72/$base $conditions':$resort['mask'];
	$name = $resort['name'];
	foreach($resort as $key=>$val) {
		if($key=='url' || $key=='mask' || $key=='name' || substr($key,-3)=='idx') {
			debugval("skipping $key\n");
			continue;
		}
		$matches=array();
		debugval("matching $key with $val\n");
		$match = preg_match($val,$report,$matches);
		if(!$match) {
			//debugval("no match, skipping $key\n");
			//continue;
			$$key = 0;
		}
		else {
			debugval($matches);
			$$key = $matches[$resort[$key.'idx']];
			if($key=='conditions') $$key = format_conditions($$key);
			$asdf = $$key;
			debugval("$key=$asdf\n");
		}
	}
	debugval('mask: '.$mask."\n");
	$code = '$output="'.$mask.'";';
	debugval('code: '.$code."\n");
	$err = eval($code);
	if($err) $output = "$name (error)";
	
	if($comma) $final.=', ';
	$final .= $output;
	$comma = true;

}	

if($final) echo "$final";
elseif($specific) echo "i don't know about $specific, but i bet there's snow there.";
else echo "something funky happened, he;lp";

//debugval($report);


?>
