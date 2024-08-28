import 'pdf_configuration_enums.dart';

class PdfConfiguration {
  final String targetDirectory;
  final String targetName;
  final PrintSize printSize;
  final PrintOrientation printOrientation;
  /// Make links clickable on iOS. But, any image will need to be set as data base64  <img src="data:image/jpeg;base64,[DATA]" />
  final bool linksClickable;
  /// `targetDirectory` is the desired path for the Pdf file.
  ///
  /// `targetName` is the name of the Pdf file
  ///
  /// `printSize` is the print size of the Pdf file
  ///
  /// `printOrientation` is the print orientation of the Pdf file
  PdfConfiguration({
    required this.targetDirectory,
    required this.targetName,
    this.printSize = PrintSize.A4,
    this.printOrientation = PrintOrientation.Portrait,
    this.linksClickable = false,
  });

  /// Returns the final path for temporary Html File
  String get htmlFilePath => "$targetDirectory/$targetName.html";
}
