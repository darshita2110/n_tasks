import 'dart:ui';

import 'package:flutter/material.dart';
import './checkbox.dart';

class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar( backgroundColor: Color.fromRGBO(
            191, 145, 83, 0.9019607843137255),
            title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top : 8.0 ),
                  child: Text('To-Do List', style: TextStyle( fontSize: 47 ,fontFamily: 'Cookie', color: Color.fromRGBO(
                      51, 47, 23, 1.0) ),),
                ),
                Icon(Icons.menu, color: Colors.black , size: 40)
              ],
            ) ),



        // body: Stack(
        //   children: [
        //     ImageFiltered( imageFilter: ImageFilter.blur(sigmaY: 4 ,sigmaX: 4),
        //       child: Container(
        //         width: double.infinity,  // Makes sure the container takes full width
        //         height: double.infinity, // Takes the full screen height
        //         decoration: const BoxDecoration(
        //             image: DecorationImage(
        //               image: AssetImage("assets/images/TODO.jpg", ), // Change to your image
        //               fit: BoxFit.cover,)),
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           SearchBox(),
        //           Padding(
        //             padding: const EdgeInsets.only(top: 8.0),
        //             child: const SizedBox(height: 10),
        //           ), // Adds spacing between SearchBox and text
        //           const Text(
        //           "  Your TODO List : ", // Change to your desired text
        //           style: TextStyle(
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //           color: Color.fromRGBO(0, 4, 2, 0.5450980392156862), fontFamily: 'Cookie')),
        //           ToDoItem(),
        //         ],
        //       ),
        //     ),
        //
        //
        //   ],
        // )

      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Color.fromRGBO(145, 77, 40, 1.0),
                decoration: InputDecoration(
                  hintText: "Add a new tasks",
                  floatingLabelStyle: TextStyle(
                    color: Color.fromRGBO(115, 69, 34, 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(140, 73, 18, 0.68),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(246, 200, 131, 0.71),
                  prefixIcon: Icon(Icons.add        ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
            SizedBox(width: 12, height: 10),
            ElevatedButton(
              onPressed: () {
                // Add your task adding logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(
                    172, 120, 26, 0.9019607843137255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Add", style: TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: Color.fromRGBO(235, 236, 235, 0.9568627450980393), fontFamily: 'Cookie')),
            ),
          ],
        ),
      ),


      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/TODO.jpg'), fit: BoxFit.cover,)
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBox(),
              Padding(
                padding: const EdgeInsets.only( bottom: 10),
                child: const SizedBox(height: 10),
              ), // Adds spacing between SearchBox and text
              const Text(
              "  Your TODO List : ", // Change to your desired text
              style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,  shadows: [Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 5.0,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),],
              color: Color.fromRGBO(235, 236, 235, 0.9568627450980393), fontFamily: 'Cardo  ')),
              ToDoItem(),
            ],
          ),
        ),
      ),
    );



  }
}

Widget SearchBox()
{
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: TextField(
      cursorColor: Color.fromRGBO(145, 77, 40, 1.0),
      decoration: InputDecoration(
          hintText: "Search...",
          floatingLabelStyle: TextStyle(color: Color.fromRGBO(
              115, 69, 34, 1.0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder( // Custom border when focused
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromRGBO(
                140, 73, 18, 0.6823529411764706), width: 2),),
          filled: true,
          fillColor: Color.fromRGBO(
              246, 200, 131, 0.7098039215686275),
          prefixIcon: Icon(Icons.search)
      ),

    ),
  );
}