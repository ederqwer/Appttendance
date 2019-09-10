import 'package:flutter/material.dart';

class CustomButtonComponent extends StatelessWidget {
  final BuildContext context;
  final String label;
  final IconData icon;
  final Function onPressed;

  const CustomButtonComponent({this.label, this.icon, this.onPressed, this.context});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.transparent,
        width: 100,
        height: 100,
        child: InkWell(
          borderRadius: BorderRadius.circular((100) / 2),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                height: 12,
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
