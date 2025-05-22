import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  DateTimeRange? selectedRange;
  bool isLoading = false;

  // Datos simulados para reportes
  List<FlSpot> ingresosMensuales = [];
  double ocupacionPromedio = 0;
  int totalReservasMes = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
    _loadData();
  }

  void _loadData() {
    // Aquí normalmente llamarías al backend con el rango de fechas
    // Para simular, creamos datos aleatorios o fijos

    setState(() {
      ingresosMensuales = [
        FlSpot(1, 1000),
        FlSpot(2, 1200),
        FlSpot(3, 1100),
        FlSpot(4, 1300),
      ];
      ocupacionPromedio = 75.5;
      totalReservasMes = 45;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
      _loadData();
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('Reporte de Hospedaje')),
        pw.Paragraph(
            text:
            'Reporte desde ${selectedRange?.start.toLocal().toString().split(' ')[0]} hasta ${selectedRange?.end.toLocal().toString().split(' ')[0]}'),
        pw.SizedBox(height: 20),

        pw.Text('Ingresos Mensuales', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headers: ['Mes', 'Ingreso'],
          data: ingresosMensuales
              .map((e) => [e.x.toInt().toString(), '\$${e.y.toStringAsFixed(2)}'])
              .toList(),
        ),
        pw.SizedBox(height: 20),

        pw.Text('Ocupación Promedio', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Paragraph(text: '${ocupacionPromedio.toStringAsFixed(1)}%'),
        pw.SizedBox(height: 20),

        pw.Text('Total Reservas del Mes', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Paragraph(text: totalReservasMes.toString()),
      ],
    ));

    return pdf;
  }

  void _exportPdf() async {
    final pdf = await _generatePdf();
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget _buildLineChart() {
    return LineChart(LineChartData(
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
            return Text('Mes ${val.toInt()}');
          }),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: ingresosMensuales,
          isCurved: true,
          barWidth: 3,
          color: Colors.blue,
          dotData: FlDotData(show: true),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes - Hospedaje'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Seleccionar rango de fechas',
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
            tooltip: 'Exportar a PDF',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            Text(
              selectedRange != null
                  ? 'Desde ${selectedRange!.start.toLocal().toString().split(' ')[0]} hasta ${selectedRange!.end.toLocal().toString().split(' ')[0]}'
                  : 'Selecciona un rango de fechas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Ingresos Mensuales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 200, child: _buildLineChart()),
            Divider(height: 40),
            ListTile(
              leading: Icon(Icons.hotel),
              title: Text('Ocupación Promedio'),
              trailing: Text('${ocupacionPromedio.toStringAsFixed(1)}%'),
            ),
            ListTile(
              leading: Icon(Icons.event_available),
              title: Text('Total Reservas del Mes'),
              trailing: Text('$totalReservasMes'),
            ),
          ],
        ),
      ),
    );
  }
}
