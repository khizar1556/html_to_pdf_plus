import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatelessWidget {
  final String path;
  final String appBarTitle;

  PDFViewer({required this.path, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
            ),
            body: SfPdfViewer.file(File(path))));
  }
}
