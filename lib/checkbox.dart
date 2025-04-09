import 'package:flutter/material.dart';

class ToDoItem extends StatefulWidget {
  const ToDoItem({super.key});

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool? isChecked=false;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10 , bottom: 10 , left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(220, 219, 217, 0.8431372549019608),
          borderRadius: BorderRadius.circular(30)
        ),

        child: Row(

          children: [
            Checkbox(

              tristate: true,
              activeColor: Color.fromRGBO(90, 61, 22, 1.0),
              value: isChecked, // A boolean value
              onChanged: (bool? newValue) {
                setState(() {
                  if (isChecked == null) {
                    isChecked = true;
                  } else if (isChecked == true) {
                    isChecked = false;
                  } else {
                    isChecked = null;
                  }
                }
                );
              },
            ),
            (isChecked!=null && isChecked==true)?
            Expanded(child: Text('todo item', style: TextStyle( fontFamily: 'Cardo', fontSize: 20, decoration: TextDecoration.lineThrough))):
            Expanded(child: Text('todo item', style: TextStyle( fontFamily: 'Cardo', fontSize: 20))),

            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.delete , color: Color.fromRGBO(135, 78, 4, 1.0)),
            ),

          ],
        )
      )
    );
  }
}

