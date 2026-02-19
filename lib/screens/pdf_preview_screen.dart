import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../themes/app_theme.dart';
import '../models/voucher_model.dart';

class PdfPreviewScreen extends StatelessWidget {
  final List<VoucherModel> vouchers;

  const PdfPreviewScreen({
    super.key,
    required this.vouchers,
  });

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    
    // Split vouchers into pages (9 per page - 3x3 grid)
    const int vouchersPerPage = 9;
    final int pageCount = (vouchers.length / vouchersPerPage).ceil();
    
    for (int page = 0; page < pageCount; page++) {
      final startIndex = page * vouchersPerPage;
      final endIndex = (startIndex + vouchersPerPage < vouchers.length)
          ? startIndex + vouchersPerPage
          : vouchers.length;
      
      final pageVouchers = vouchers.sublist(startIndex, endIndex);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.GridView(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              children: pageVouchers.map((voucher) => _buildVoucherCard(voucher)).toList(),
            );
          },
        ),
      );
    }
    
    return pdf;
  }

  pw.Widget _buildVoucherCard(VoucherModel voucher) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'COGONA NET',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Username:',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            voucher.code,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (voucher.password != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Password: ${voucher.password}',
              style: pw.TextStyle(fontSize: 8),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            '${voucher.dataLimit}GB - ${voucher.timeLimit}h',
            style: pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('معاينة الطباعة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final pdf = await _generatePdf();
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: 'cogona_vouchers_${DateTime.now().millisecondsSinceEpoch}.pdf',
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          final pdf = await _generatePdf();
          return pdf.save();
        },
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'cogona_vouchers.pdf',
      ),
    );
  }
}
