import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? selectedRange;
  bool isLoading = false;
  String errorMessage = '';

  List<FlSpot> ingresosMensuales = [];
  List<BarChartGroupData> ocupacionHoteles = [];
  List<PieChartSectionData> platosMasVendidos = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    if (selectedRange == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.12:8080/api/reports?start=${selectedRange!.start.toIso8601String()}&end=${selectedRange!.end.toIso8601String()}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          ingresosMensuales = (data['ingresos'] as List)
              .map((e) => FlSpot(e['mes'].toDouble(), e['valor'].toDouble()))
              .toList();

          ocupacionHoteles = (data['ocupacion'] as List)
              .asMap()
              .entries
              .map((entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                  toY: entry.value['ocupacion'].toDouble(),
                  color: Colors.blueAccent)
            ],
            showingTooltipIndicators: [0],
          ))
              .toList();

          platosMasVendidos = (data['platos'] as List)
              .map((e) => PieChartSectionData(
            value: e['ventas'].toDouble(),
            title: e['plato'],
            color: Colors.primaries[
            e['plato'].hashCode % Colors.primaries.length],
            radius: 50,
            titleStyle: TextStyle(fontSize: 12, color: Colors.white),
          ))
              .toList();
        });
      } else {
        setState(() {
          errorMessage = 'Error cargando datos de reportes';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickDateRange() async {
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
      fetchReportData();
    }
  }

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('Reporte de Turismo y Gastronomía')),
        pw.Paragraph(
            text:
            'Reporte desde ${selectedRange?.start.toLocal().toString().split(' ')[0]} hasta ${selectedRange?.end.toLocal().toString().split(' ')[0]}'),
        pw.SizedBox(height: 20),

        pw.Text('Ingresos Mensuales:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: ingresosMensuales.isEmpty ? 'Sin datos' : ''),
        if (ingresosMensuales.isNotEmpty)
          pw.Table.fromTextArray(
            headers: ['Mes', 'Ingreso'],
            data: ingresosMensuales
                .map((e) => [e.x.toInt().toString(), '\$${e.y.toStringAsFixed(2)}'])
                .toList(),
          ),

        pw.SizedBox(height: 20),

        pw.Text('Ocupación Hoteles (%):', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: ocupacionHoteles.isEmpty ? 'Sin datos' : ''),
        if (ocupacionHoteles.isNotEmpty)
          pw.Table.fromTextArray(
            headers: ['Hotel', 'Ocupación'],
            data: ocupacionHoteles
                .asMap()
                .entries
                .map((entry) => ['Hotel ${entry.key + 1}', '${entry.value.barRods[0].toY}%'])
                .toList(),
          ),

        pw.SizedBox(height: 20),

        pw.Text('Platos más vendidos:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: platosMasVendidos.isEmpty ? 'Sin datos' : ''),
        if (platosMasVendidos.isNotEmpty)
          pw.Table.fromTextArray(
            headers: ['Plato', 'Ventas'],
            data: platosMasVendidos
                .map((e) => [e.title, e.value.toStringAsFixed(0)])
                .toList(),
          ),
      ],
    ));

    return pdf;
  }

  void onExportPressed() async {
    final pdf = await generatePdf();
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: pickDateRange,
            tooltip: 'Seleccionar rango fechas',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: onExportPressed,
            tooltip: 'Exportar reporte a PDF',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              selectedRange != null
                  ? 'Reportes desde ${selectedRange!.start.toLocal().toString().split(' ')[0]} hasta ${selectedRange!.end.toLocal().toString().split(' ')[0]}'
                  : 'Selecciona un rango de fechas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            Text('Ingresos Mensuales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 200,
              child: ingresosMensuales.isEmpty
                  ? Center(child: Text('No hay datos'))
                  : LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        return Text('Mes ${value.toInt()}');
                      }),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: ingresosMensuales, isCurved: true, color: Colors.blue)
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            Text('Ocupación Hoteles (%)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 200,
              child: ocupacionHoteles.isEmpty
                  ? Center(child: Text('No hay datos'))
                  : BarChart(BarChartData(
                barGroups: ocupacionHoteles,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < ocupacionHoteles.length) {
                          final name = 'Hotel ${value.toInt() + 1}';
                          return Text(name);
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
              )),
            ),
            SizedBox(height: 32),

            Text('Platos más vendidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 200,
              child: platosMasVendidos.isEmpty
                  ? Center(child: Text('No hay datos'))
                  : PieChart(PieChartData(sections: platosMasVendidos, sectionsSpace: 2)),
            ),
          ],
        ),
      ),
    );
  }
}
