
// @dart=2.9
import 'dart:convert';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'apptitle.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment 6',
      theme: ThemeData(
       
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage():super();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String base64Image; //Store img
  String fileName; //Store file Name
  String status; //For upload status
  File _image; //Store image pick from Gallery and Camera
  PickedFile pickedImage; //Store the Picked Image
  int bytes; //Store img Size
  int i=0;
  String size=""; //Display Size
  bool loading=false; //Loader

//Function To Upload Img From Camera
 _imgFromCamera() async {
  pickedImage = await ImagePicker().getImage(
    source: ImageSource.camera, imageQuality: 50
  );
    setState(() {
    _image = File(pickedImage.path);
     bytes=_image.lengthSync(); //Get File Size
      String format=fileFormat();
      print(bytes);
    //If File Size is Greater Than 2MB Then Give Error
   if(bytes>2000000)
     {
     showAlertDialog(context,'File Size Error','The size of the file should be less than or equal to 2mb. Try Again!');
     setState(() {
     _image=null;
      bytes=0;
     size="";
      });
     }
     //If Image is Not in jpg Format Show Alert
     else if (format!='jpg')
     { 
       showAlertDialog(context,'File Format Error','The file must be in jpg format. Try Again!');
        setState(() {
     _image=null;
      bytes=0;
     size="";
      });
     }
     else{
    size=filesize(bytes);}
  });
}

//Function to Upload Image From Files
_imgFromGallery() async {
  FilePickerResult result = await FilePicker.platform.pickFiles();
  PlatformFile fl=result.files.first;
    setState(() {
      pickedImage=PickedFile(fl.path);//Picked File
    _image = File(fl.path);
     bytes=_image.lengthSync(); //Check img Size
      String format=fileFormat();
    print(bytes);
    //Show Alert if img is larger than 2mb
    if(bytes>2000000)
     {
     showAlertDialog(context,'File Size Error','The size of the file should be less than or equal to 2mb. Try Again!');
     setState(() {
     _image=null;
      bytes=0;
     size="";
      });
     }
     //If file is not jpg show error
     else if (format!='jpg')
     { 
       showAlertDialog(context,'File Format Error','The file must be in jpg format. Try Again!');
        setState(() {
     _image=null;
      bytes=0;
     size="";
      });
     }
     else{
    size=filesize(bytes);}
  });
}

//Function to Return File Extension
String fileFormat()
{
  String format=_image.path.split('/').last;
  String ext=format.substring(format.length-3);
  print(ext);
  return ext;
}

//Function to Upload img on Rest Api
void uploadImage()
{
  setState(() {
    loading=true;
    base64Image=base64Encode(_image.readAsBytesSync());//read file
    fileName=_image.path.split('/').last;}); //store file name
  //Post  on Rest Api
  http.post('https://pcc.edu.pk/ws/file_upload.php',body:{
    "image":base64Image,
     "name":fileName
  }).then((result){
  setState(() {
    var res=jsonDecode(result.body);
    status=res['message'];
    loading=false;
    showAlertDialog(context, 'Response', status);
  });
  }).catchError((error){
    showAlertDialog(context, 'ERROR', error);
  });
}

//Function to Apply Cropping
_croppImage (PickedFile pickedImage) async {
File croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedImage.path,
         maxWidth: 1080,
        maxHeight: 1080,
    );
      setState(() {
    _image = File(croppedImage.path);
  });
}

//Function to Compress Image Size
void compressImage(File file) async{

Directory appDocumentsDirectory=await getApplicationDocumentsDirectory();
String appDocumentsPath=appDocumentsDirectory.path;
String filePath='$appDocumentsPath/$i.jpg'; //path to store image locally
var compressedImage=await FlutterImageCompress.compressAndGetFile(
file.path,
filePath,
minHeight: 500,
minWidth: 500,
quality:50
);
setState(() {
    _image =compressedImage;
    bytes=_image.lengthSync();
    size=filesize(bytes);
  });
}

//Alert Dialog Function
showAlertDialog(BuildContext context,String header,String txt)
{
  Widget okButton=ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: Text('Ok'));
  AlertDialog res=AlertDialog(title: Text(header),
  content: Text(txt),
  actions: [okButton],);
  showDialog(context: context, builder: (BuildContext context){
    return res;
  }
  );
}

//Show Image Picker function
void _showPicker(context)
{
  showModalBottomSheet(context: context, builder: (BuildContext bc){
    return SafeArea(child:Container(
      height: 150,
      child: new Wrap(
      children: [
        new ListTile(leading: new Icon(Icons.photo_library,color:Colors.red),
        title: Text('Gallery'),
        onTap:() {
          _imgFromGallery();
          Navigator.of(context).pop();}),
          new ListTile(leading: new Icon(Icons.photo_camera,color: Colors.red,),
        title: Text('Camera'),
        onTap:() {
          _imgFromCamera();
          Navigator.of(context).pop();}), 
      ],
    ),));
  });
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(   
        title: AppTitle(),
      ),
      body:loading==false?
      SingleChildScrollView(
      child:Column(
          children: [            
            Padding(
              padding: EdgeInsets.fromLTRB(0,60,0,0),
              child: CircleAvatar(
              radius: 130,
              backgroundColor: Colors.grey[300],
              child:_image == null?
                Container(
                width:255,
                height:255,
                decoration: BoxDecoration(
                color:Colors.grey[200],
                borderRadius: BorderRadius.circular(200)),
                 child:IconButton(icon: Icon(Icons.camera_alt,size:40,color:Colors.blueGrey),
                 onPressed: (){
                 _showPicker(context);
                 },)
                )
          :ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Image.file(
                        _image,
                        width: 245,
                        height: 245,
                        fit: BoxFit.fitHeight,
                      ),
                    )
          )),
          Padding(
            padding: EdgeInsets.fromLTRB(0,20,0,0),
            child: Text(size),
          ),

          Padding(
            padding:EdgeInsets.fromLTRB(0,30,0,0),
            child:ButtonBar(
            alignment: MainAxisAlignment.center,
            children:[
              ElevatedButton.icon(
                icon:Icon(Icons.crop,color: Colors.white),
                label: Text('Crop',style: TextStyle(fontSize: 20),),onPressed: (){
              _croppImage(pickedImage);
              
            },style: ElevatedButton.styleFrom(primary:Colors.blue,
                 padding: EdgeInsets.symmetric(horizontal:40,vertical:10),
                 shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(10.0))))
            ),
              ElevatedButton.icon(
                icon:Icon(Icons.compress,color: Colors.white),
                label: Text('Compress',style: TextStyle(fontSize: 20),),onPressed: (){
                  setState(() {
                   i=i+1;
                   });
                compressImage(_image);
              
            },style: ElevatedButton.styleFrom(primary:Colors.blue,
                 padding: EdgeInsets.symmetric(horizontal:20,vertical:10),
                 shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(10.0))))
            )
            ],
            )),

          Center(
            child:  Padding(
                padding:EdgeInsets.fromLTRB(0,30,0,0),
              child:ElevatedButton.icon(
                icon:Icon(Icons.upload,color: Colors.white),
                label: Text('Upload',style: TextStyle(fontSize: 20),),onPressed: (){
              uploadImage();
              
            },style: ElevatedButton.styleFrom(primary:Colors.red,
                 padding: EdgeInsets.symmetric(horizontal:60,vertical:10),
                 shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(10.0))))
            )),
             
            ),
               Align(alignment: Alignment.bottomRight,
            child:Padding(
              padding: EdgeInsets.fromLTRB(0,40,20,0),
              child:CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
           child:Container(
             width:255,
             height:255,
             decoration: BoxDecoration(
             color:Colors.red,
             borderRadius: BorderRadius.circular(200)),
             child:IconButton(icon: Icon(Icons.camera_alt,size:40,color:Colors.white),
             onPressed: (){
              _showPicker(context);
             },)
             )))),
          ],),
      ):Center(child:CircularProgressIndicator()), 
        );
  }
}
