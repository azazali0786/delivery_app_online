import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoicePdfHelper {
  // Company Details
  static const String companyName = 'DMAK Agriculture Private Limited';
  static const String productName = 'Alive Milk';
  static const String companyAddress = 'Rafiqabad Colony Dasna (GZB) 201015';
  static const String appName = 'Alive Milk';
  static const String appLink =
      'https://play.google.com/store/apps/details?id=com.milkaliveapp.app';
  static const String phone = '+91 72918 03311';
  static const String email = 'support@alivemilk.com';
  static const String gstin = '09AALCD2883Q1ZQ';

  // Load logo
  static Future<Uint8List?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // Build company header
  static pw.Widget _buildHeader(pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null)
                pw.Container(width: 60, height: 60, child: pw.Image(logo))
              else
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'AM',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              pw.SizedBox(width: 15),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    productName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.blue700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        companyAddress,
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        '                                                           GSTIN: $gstin',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build footer
  static pw.Widget _buildFooter(
    pw.Context context,
    int pageNumber,
    int totalPages,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Download App: $appName',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                appLink,
                style: pw.TextStyle(fontSize: 7, color: PdfColors.blue700),
              ),
            ],
          ),
          pw.Text(
            'Page $pageNumber of $totalPages',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  // Build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label:',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Build table header
  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Build table cell
  static pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, color: color ?? PdfColors.black),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Build summary row
  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  // Generate Invoice PDF
  static Future<void> generateInvoicePdf({
    required String customerName,
    required String customerPhone,
    required String? customerAddress,
    required String areaName,
    required String subAreaName,
    required double permanentQuantity,
    required List<Map<String, dynamic>> entries,
  }) async {
    if (entries.isEmpty) {
      throw Exception('No entries found for the selected period');
    }

    final doc = pw.Document();
    final logoData = await _loadLogo();
    final logo = logoData != null ? pw.MemoryImage(logoData) : null;

    // Calculate totals
    double totalMilk = 0;
    double totalAmount = 0;
    double totalCollected = 0;

    for (var entry in entries) {
      final milkQty = double.tryParse(entry['milk_quantity'].toString()) ?? 0.0;
      final rate = double.tryParse(entry['rate'].toString()) ?? 0.0;
      final collected =
          double.tryParse(entry['collected_money'].toString()) ?? 0.0;

      totalMilk += milkQty;
      totalAmount += milkQty * rate;
      totalCollected += collected;
    }

    final balance = totalAmount - totalCollected;
    final invoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => _buildHeader(logo),
        footer: (context) =>
            _buildFooter(context, context.pageNumber, context.pagesCount),
        build: (context) {
          return [
            pw.SizedBox(height: 20),

            // Invoice Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Invoice #: $invoiceNo',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: balance > 0 ? PdfColors.red100 : PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(
                      color: balance > 0 ? PdfColors.red : PdfColors.green,
                      width: 2,
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        balance > 0 ? 'AMOUNT DUE' : 'Overpaid',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: balance > 0
                              ? PdfColors.red900
                              : PdfColors.green900,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${balance.abs().toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: balance > 0
                              ? PdfColors.red900
                              : PdfColors.green900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            // Customer Details
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        if (customerAddress != null &&
                            customerAddress.isNotEmpty)
                          pw.Text(
                            customerAddress,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$areaName / $subAreaName',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (customerPhone.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Phone: $customerPhone',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SUMMARY',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _buildInfoRow(
                          'Period',
                          '${DateFormat('dd/MM/yy').format(DateTime.parse(entries.first['entry_date']))} - ${DateFormat('dd/MM/yy').format(DateTime.parse(entries.last['entry_date']))}',
                        ),
                        _buildInfoRow('Total Deliveries', '${entries.length}'),
                        _buildInfoRow(
                          'Permanent Qty',
                          '${permanentQuantity.toStringAsFixed(1)} L',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            // Entries Table
            pw.Text(
              'Delivery Details',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.2),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  children: [
                    _buildTableHeader('Date'),
                    _buildTableHeader('Quantity (L)'),
                    _buildTableHeader('Rate'),
                    _buildTableHeader('Amount'),
                    _buildTableHeader('Paid'),
                    _buildTableHeader('Balance'),
                  ],
                ),
                // Rows
                ...entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final milkQty =
                      double.tryParse(data['milk_quantity'].toString()) ?? 0.0;
                  final rate = double.tryParse(data['rate'].toString()) ?? 0.0;
                  final collected =
                      double.tryParse(data['collected_money'].toString()) ??
                      0.0;
                  final amount = milkQty * rate;
                  final balance = amount - collected;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index % 2 == 0
                          ? PdfColors.white
                          : PdfColors.grey100,
                    ),
                    children: [
                      _buildTableCell(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(DateTime.parse(data['entry_date'])),
                      ),
                      _buildTableCell(milkQty.toStringAsFixed(1)),
                      _buildTableCell(rate.toStringAsFixed(0)),
                      _buildTableCell(amount.toStringAsFixed(2)),
                      _buildTableCell(collected.toStringAsFixed(2)),
                      _buildTableCell(
                        balance.toStringAsFixed(2),
                        color: balance > 0
                            ? PdfColors.red700
                            : PdfColors.green700,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Total Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow(
                        'Total Milk',
                        '${totalMilk.toStringAsFixed(1)} L',
                      ),
                      pw.Divider(color: PdfColors.grey400),
                      _buildSummaryRow(
                        'Total Amount',
                        '${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      _buildSummaryRow(
                        'Total Paid',
                        '${totalCollected.toStringAsFixed(2)}',
                      ),
                      pw.Divider(color: PdfColors.grey400),
                      _buildSummaryRow(
                        balance > 0 ? 'Balance Due' : 'Overpaid',
                        '${balance.abs().toStringAsFixed(2)}',
                        isBold: true,
                        color: balance > 0 ? PdfColors.red : PdfColors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Thank you note
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Thank you for choosing us!',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    email,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 7),
            pw.Text(
              'All amounts are denominated in Rupees.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'Invoice_${customerName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
