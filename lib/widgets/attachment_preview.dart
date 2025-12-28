import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class AttachmentPreview extends StatelessWidget {
  final String path;

  const AttachmentPreview({super.key, required this.path});

  bool get isImage =>
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png');

  bool get isPdf => path.endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    if (isImage) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _ImagePreview(path: path),
            ),
          );
        },
        child: Image.file(
          File(path),
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    if (isPdf) {
      return ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(path.split('/').last),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _PdfPreview(path: path),
            ),
          );
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.insert_drive_file),
      title: Text(path.split('/').last),
      onTap: () => OpenFilex.open(path),
    );
  }
}

/// IMAGE VIEW
class _ImagePreview extends StatelessWidget {
  final String path;

  const _ImagePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.file(File(path)),
      ),
    );
  }
}

/// PDF VIEW
class _PdfPreview extends StatelessWidget {
  final String path;

  const _PdfPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: PDFView(filePath: path),
    );
  }
}
