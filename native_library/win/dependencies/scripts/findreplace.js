var FSOObj = new ActiveXObject("Scripting.FileSystemObject");
var ARGS = WScript.Arguments;
WScript.Echo(WScript.Arguments(0));
WScript.Echo(WScript.Arguments(1));
WScript.Echo(WScript.Arguments(2));
if (ARGS.Length < 3 ) {
 WScript.Echo("Wrong arguments");
 WScript.Quit(1);
}
var filename=ARGS.Item(0);
var find=ARGS.Item(1);
var replace=ARGS.Item(2);

var readStream=FSOObj.OpenTextFile(filename, 1);

var content=readStream.ReadAll();
readStream.Close();

function replaceAll(find, replace, str) {
  return str.replace(new RegExp(find, 'g'), replace);
}

var newConten=replaceAll(find,replace,content);

var writeStream=FSOObj.OpenTextFile(filename, 2);
writeStream.WriteLine(newConten);
writeStream.Close();