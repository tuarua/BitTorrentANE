var FSOObj = new ActiveXObject("Scripting.FileSystemObject");
var ARGS = WScript.Arguments;
var filename=ARGS.Item(0);
var find=ARGS.Item(1);
var replace=ARGS.Item(2);
var secondaryReplace;
if(ARGS.Item(3) == 0){
	secondaryReplace = replace;
}else{
	secondaryReplace = replaceAll('\\\\','\\\\',replace);
}
var readStream=FSOObj.OpenTextFile(filename, 1);
var content=readStream.ReadAll();
readStream.Close();
function replaceAll(find, replace, str) {
  return str.replace(new RegExp(find, 'g'), replace);
}
var newContent=replaceAll(find,secondaryReplace,content);
var writeStream=FSOObj.OpenTextFile(filename, 2);
writeStream.WriteLine(newContent);
writeStream.Close();