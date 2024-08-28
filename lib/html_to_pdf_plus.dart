import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:html_to_pdf_plus/file_utils.dart';

import 'pdf_configuration.dart';
import 'pdf_configuration_enums.dart';

export 'pdf_configuration.dart';
export 'pdf_configuration_enums.dart';

/// HTML to PDF Converter
class HtmlToPdf {
  static const MethodChannel _channel =
      const MethodChannel('flutter_html_to_pdf');

  /// Creates PDF Document from HTML content
  /// Can throw a [PlatformException] or (unlikely) a [MissingPluginException] converting html to pdf
  static Future<File> convertFromHtmlContent({
    required String htmlContent,
    required PdfConfiguration configuration,
  }) async {
    final File temporaryCreatedHtmlFile =
        await FileUtils.createFileWithStringContent(
      htmlContent,
      configuration.htmlFilePath,
    );
    await FileUtils.appendStyleTagToHtmlFile(temporaryCreatedHtmlFile.path);

    final String generatedPdfFilePath = await _convertFromHtmlFilePath(
      temporaryCreatedHtmlFile.path,
      configuration.printSize,
      configuration.printOrientation,
      configuration.linksClickable,
    );

    temporaryCreatedHtmlFile.delete();

    return FileUtils.copyAndDeleteOriginalFile(
      generatedPdfFilePath,
      configuration.targetDirectory,
      configuration.targetName,
    );
  }

  /// Creates PDF Document from File that contains HTML content
  /// Can throw a [PlatformException] or (unlikely) a [MissingPluginException] converting html to pdf
  static Future<File> convertFromHtmlFile({
    required File htmlFile,
    required PdfConfiguration configuration,
  }) async {
    await FileUtils.appendStyleTagToHtmlFile(htmlFile.path);
    final String generatedPdfFilePath = await _convertFromHtmlFilePath(
      htmlFile.path,
      configuration.printSize,
      configuration.printOrientation,
      configuration.linksClickable,
    );

    return FileUtils.copyAndDeleteOriginalFile(
      generatedPdfFilePath,
      configuration.targetDirectory,
      configuration.targetName,
    );
  }

  /// Creates PDF Document from path to File that contains HTML content
  /// Can throw a [PlatformException] or (unlikely) a [MissingPluginException] converting html to pdf
  static Future<File> convertFromHtmlFilePath({
    required String htmlFilePath,
    required PdfConfiguration configuration,
  }) async {
    await FileUtils.appendStyleTagToHtmlFile(htmlFilePath);
    final generatedPdfFilePath = await _convertFromHtmlFilePath(
      htmlFilePath,
      configuration.printSize,
      configuration.printOrientation,
      configuration.linksClickable,
    );
    final generatedPdfFile = FileUtils.copyAndDeleteOriginalFile(
        generatedPdfFilePath,
        configuration.targetDirectory,
        configuration.targetName);

    return generatedPdfFile;
  }

  /// Assumes the invokeMethod call will return successfully
  static Future<String> _convertFromHtmlFilePath(
    String htmlFilePath,
    PrintSize printSize,
    PrintOrientation printOrientation,
    bool linksClickable,
  ) async {
    int width = printSize
        .getDimensionsInPixels[printOrientation.getWidthDimensionIndex];
    int height = printSize
        .getDimensionsInPixels[printOrientation.getHeightDimensionIndex];

    return await _channel.invokeMethod(
      'convertHtmlToPdf',
      <String, dynamic>{
        'htmlFilePath': htmlFilePath,
        'width': width,
        'height': height,
        'printSize': printSize.printSizeKey,
        'orientation': printOrientation.orientationKey,
        'linksClickable': linksClickable,
      },
    ) as String;
  }
}
