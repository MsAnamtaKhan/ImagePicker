import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget{
AppTitle();
@override
Widget build(BuildContext context)
{
  return Padding(padding:EdgeInsets.fromLTRB(90, 10, 10, 0),child: Text('Image Picker',style:TextStyle(fontSize: 25,color:Colors.white,fontWeight: FontWeight.bold)),);
}
}