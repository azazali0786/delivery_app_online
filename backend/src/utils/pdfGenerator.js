const PDFDocument = require('pdfkit');

class PDFGenerator {
  static generateInvoice(customer, entries, startDate, endDate) {
    return new Promise((resolve, reject) => {
      try {
        const doc = new PDFDocument({ margin: 50 });
        const chunks = [];

        doc.on('data', chunk => chunks.push(chunk));
        doc.on('end', () => resolve(Buffer.concat(chunks)));
        doc.on('error', reject);

        // Header
        doc.fontSize(20).text('MILK DELIVERY INVOICE', { align: 'center' });
        doc.moveDown();

        // Customer Details
        doc.fontSize(12).text(`Customer Name: ${customer.name}`);
        doc.text(`Phone: ${customer.phone_number}`);
        doc.text(`Address: ${customer.address || 'N/A'}`);
        doc.moveDown();

        // Date Range
        doc.text(`Invoice Period: ${startDate} to ${endDate}`);
        doc.moveDown();

        // Table Header
        doc.fontSize(10);
        const tableTop = doc.y;
        const col1 = 50;
        const col2 = 120;
        const col3 = 220;
        const col4 = 300;
        const col5 = 380;
        const col6 = 460;

        doc.text('Date', col1, tableTop);
        doc.text('Quantity (L)', col2, tableTop);
        doc.text('Rate (₹)', col3, tableTop);
        doc.text('Amount (₹)', col4, tableTop);
        doc.text('Collected (₹)', col5, tableTop);
        doc.text('Balance (₹)', col6, tableTop);

        doc.moveTo(col1, tableTop + 15).lineTo(550, tableTop + 15).stroke();
        doc.moveDown();

        // Table Rows
        let totalAmount = 0;
        let totalCollected = 0;
        let yPosition = tableTop + 25;

        entries.forEach(entry => {
          const amount = entry.milk_quantity * entry.rate;
          const balance = amount - entry.collected_money;
          
          totalAmount += amount;
          totalCollected += entry.collected_money;

          doc.text(entry.entry_date, col1, yPosition);
          doc.text(entry.milk_quantity.toFixed(2), col2, yPosition);
          doc.text(entry.rate.toFixed(2), col3, yPosition);
          doc.text(amount.toFixed(2), col4, yPosition);
          doc.text(entry.collected_money.toFixed(2), col5, yPosition);
          doc.text(balance.toFixed(2), col6, yPosition);

          yPosition += 20;

          // Add new page if needed
          if (yPosition > 700) {
            doc.addPage();
            yPosition = 50;
          }
        });

        // Total Line
        doc.moveTo(col1, yPosition).lineTo(550, yPosition).stroke();
        yPosition += 10;

        // Totals
        doc.fontSize(12);
        doc.text('TOTAL:', col3, yPosition, { bold: true });
        doc.text(`₹${totalAmount.toFixed(2)}`, col4, yPosition);
        doc.text(`₹${totalCollected.toFixed(2)}`, col5, yPosition);
        doc.text(`₹${(totalAmount - totalCollected).toFixed(2)}`, col6, yPosition);

        yPosition += 30;

        // Summary
        doc.moveDown(2);
        doc.fontSize(11);
        doc.text(`Total Amount: ₹${totalAmount.toFixed(2)}`);
        doc.text(`Total Collected: ₹${totalCollected.toFixed(2)}`);
        doc.text(`Pending Balance: ₹${(totalAmount - totalCollected).toFixed(2)}`);

        // Footer
        doc.moveDown(3);
        doc.fontSize(10);
        doc.text('Thank you for your business!', { align: 'center' });
        doc.text('For any queries, please contact us.', { align: 'center' });

        doc.end();
      } catch (error) {
        reject(error);
      }
    });
  }
}

module.exports = PDFGenerator;