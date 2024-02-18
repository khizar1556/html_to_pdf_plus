# html_to_pdf_plus
<!---Html to PDF Flutter--->
[![pub package](https://img.shields.io/pub/v/html_to_pdf_plus.svg)](https://pub.dartlang.org/packages/html_to_pdf_plus)

Flutter plugin for generating PDF files from HTML
<!---Html to PDF Flutter--->
# Screenshots
<!---Html to PDF Flutter--->
<img src="https://raw.githubusercontent.com/khizar1556/html_to_pdf_plus/main/Screenshot_20231227_235800.png" alt="image" width="40%" height="auto">

### Usage
<!---Html to PDF Flutter--->
```dart
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

var targetPath = "/your/sample/path";
var targetFileName = "example_pdf_file";

final generatedPdfFile = await HtmlToPdf.convertFromHtmlContent(
htmlContent: htmlContent,
configuration: PdfConfiguration(
targetDirectory: targetPath,
targetName: targetFileName,
printSize: PrintSize.A4,
printOrientation: PrintOrientation.Landscape,
));

```
<!---Html to PDF Flutter--->
Code above simply generates **PDF** file from **HTML** content. It should work with most of common HTML markers. You don’t need to add *.pdf* extension to ***targetFileName*** because plugin only generates PDF files and extension will be added automatically.
#### Other Usages
<!---Html to PDF Flutter--->
You can also pass ***File*** object with **HTML** content inside as parameter
```dart
var file = File("/sample_path/example.html");
var generatedPdfFile = await HtmlToPdf.convertFromHtmlFile(
    file, targetPath, targetFileName);
```

or even just path to this file
```dart
var filePath = "/sample_path/example.html";
var generatedPdfFile = await HtmlToPdf.convertFromHtmlFilePath(
    filePath, targetPath, targetFileName);
```

#### Images
<!---Html to PDF Flutter--->
If your want to add local image from device to your **HTML** you need to pass path to image as ***src*** value.

```html
<img src="file:///storage/example/your_sample_image.png" alt="web-img">
```
or if you want to use the image ***File*** object
```html
<img src="${imageFile.path}" alt="web-img">
```

Many images inside your document can significantly affect the final file size so I suggest to use [flutter_image_compress](https://github.com/OpenFlutter/flutter_image_compress) plugin.
<!---Html to PDF Flutter--->


