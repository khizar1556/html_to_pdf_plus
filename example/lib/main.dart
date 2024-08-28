import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html_to_pdf_plus/html_to_pdf_plus.dart';
import 'package:flutter_html_to_pdf_example/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String generatedPdfFilePath = "";

  @override
  void initState() {
    super.initState();
    generateExampleDocument();
  }

  Future<void> generateExampleDocument() async {
    final htmlContent = """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
        th, td, p {
          padding: 5px;
          text-align: left;
        }
        </style>
      </head>
      <body>
        <h2>PDF Generated with html_to_pdf_plus plugin</h2>
        
        <table style="width:100%">
          <caption>Sample HTML Table</caption>
          <tr>
            <th>Portfolio</th>
            <th>Link</th>
          </tr>
          <tr>
            <td>Website</td>
            <td><a href="https://khizarrehman.com/">https://khizarrehman.com/</a></td>
          </tr>
          <tr>
            <td>Fiverr</td>
            <td><a href="https://www.fiverr.com/ranakhizar">https://www.fiverr.com/ranakhizar</a></td>
         </tr> 
        </table>
        
        <img src="https://avatars.githubusercontent.com/u/32544554?v=4" alt="web-img">
      </body>
    </html>
    """;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final targetPath = appDocDir.path;
    final targetFileName = "example-pdf";

    final generatedPdfFile = await HtmlToPdf.convertFromHtmlContent(
        htmlContent: htmlContent,
        configuration: PdfConfiguration(
          targetDirectory: targetPath,
          targetName: targetFileName,
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Portrait,
          linksClickable: true
        ));
    generatedPdfFilePath = generatedPdfFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          child: Text("Open Generated PDF Preview"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PDFViewer(
                      appBarTitle: "Generated PDF Document",
                      path: generatedPdfFilePath)),
            );
          },
        ),
      ),
    ));
  }
}
