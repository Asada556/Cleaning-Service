import 'dart:async';

import 'package:cleaning_service/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Modal {
  show(
    BuildContext context, {
    String? title,
    Widget? body,
    double? width,
    double? height,
    List<Widget>? actions,
    MainAxisAlignment actionMainAxisAlignment = MainAxisAlignment.spaceBetween,
    Duration? duration,
  }) async {
    Timer timer = Timer(
      duration != null ? duration : Duration(days: 1),
      () {
        Navigator.pop(context, "duration");
      },
    );

    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          elevation: 0,
          content: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kLightBlue,
            ),
            height: height,
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                title != null
                    ? Text(
                        title,
                        style: TextStyle(
                          fontSize: 36,
                        ),
                      )
                    : SizedBox(),
                body != null ? body : SizedBox(),
                Row(
                  mainAxisAlignment: actionMainAxisAlignment,
                  children: actions != null ? actions : [],
                )
              ],
            ),
          ),
        );
      },
    );

    timer.cancel();
    return result;
  }

  viewImage(BuildContext context, Image image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final size = MediaQuery.of(context).size;

        return Container(
          color: Colors.black,
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  color: Colors.black,
                  child: Text(
                    "ปิด",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: Container(
                  color: Colors.amber,
                  child: ClipRRect(
                    child: PhotoView(
                      imageProvider: image.image,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
