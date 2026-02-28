import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';

class PetMetricsPdfService {
  // Configurações exatas do Domínio e Restrições de Hardware (SM A256E)
  static const PdfColor _colorBackground = PdfColor.fromInt(0xFFFFFFFF); // Branco Puro
  static const PdfColor _colorCardBg = PdfColor.fromInt(0xFFF9F9F9); // Gelo Metálico Escovado
  static const PdfColor _colorText = PdfColor.fromInt(0xFF000000); // Preto Absoluto
  static const PdfColor _colorTheme = PdfColor.fromInt(0xFFFC2D7C); // Rosa Intenso / Magenta
  static const PdfColor _colorTextDim = PdfColor.fromInt(0xFF666666); // Cinza Escuro

  static Future<Uint8List> generateMetricsPdf({
    required String petName,
    required String breed,
    required List<PetEvent> metricsEvents,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Fontes
    final fontData = await PdfGoogleFonts.robotoRegular();
    final boldFontData = await PdfGoogleFonts.robotoBold();
    
    // Agrupar eventos por métrica
    final Map<String, List<pw.Widget>> charts = _buildCharts(metricsEvents, _colorTheme, l10n);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.applyMargin(
            left: 1.5 * PdfPageFormat.cm,
            top: 1.5 * PdfPageFormat.cm,
            right: 1.5 * PdfPageFormat.cm,
            bottom: 1.5 * PdfPageFormat.cm,
          ),
          theme: pw.ThemeData.withFont(
            base: fontData,
            bold: boldFontData,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _colorBackground),
          ),
        ),
        header: (context) => _buildHeader(petName, dateStr, l10n),
        footer: (context) => _buildFooter(context, l10n),
        build: (context) => [
          // Cartão de Identidade
          _buildIdentityCard(petName, breed),
          pw.SizedBox(height: 20),

          // Título do Relatório
          pw.Text(
            l10n.pdf_scannut_module('Evolução de Métricas Clínicas').toUpperCase(),
            style: pw.TextStyle(color: _colorTheme, fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          // Se nenhuma métrica tiver dados suficientes
          if (charts.isEmpty)
             pw.Text(
               'Nenhuma métrica com dados históricos suficientes para gerar gráficos.',
               style: const pw.TextStyle(color: _colorTextDim, fontSize: 12),
             )
          else
             ...charts.values.expand((widgetList) => widgetList),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String petName, String dateStr, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _colorTheme, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "ScanNut+: Meu Pet: $petName",
            style: pw.TextStyle(color: _colorTheme, fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            l10n.pdf_date(dateStr),
            style: const pw.TextStyle(color: _colorTextDim, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _colorTheme, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "Página ${context.pageNumber} | © 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br",
            style: pw.TextStyle(color: _colorTheme, fontSize: 8),
          ),
          pw.Text(
            "Página ${context.pageNumber} de ${context.pagesCount}",
            style: const pw.TextStyle(color: _colorTextDim, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildIdentityCard(String name, String breed) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _colorCardBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _colorTheme, width: 1.5),
        boxShadow: const [
          pw.BoxShadow(color: PdfColors.grey300, offset: PdfPoint(2, 2), blurRadius: 2),
        ]
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
             children: [
                pw.Text('Nome: ', style: pw.TextStyle(color: _colorText, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(name, style: const pw.TextStyle(color: _colorText, fontSize: 14)),
             ]
          ),
          pw.Row(
             children: [
                pw.Text('Raça: ', style: pw.TextStyle(color: _colorText, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(breed, style: const pw.TextStyle(color: _colorText, fontSize: 14)),
             ]
          )
        ],
      ),
    );
  }

  // Define chaves e labels pareados com a UI (evitando importações circulares complexas)
  static final _metricDefinitions = [
    {'key': 'weight', 'label': 'Peso'},
    {'key': 'bpm', 'label': 'Frequência Cardíaca (bpm)'},
    {'key': 'mpm', 'label': 'Movimentos por Minuto (mpm)'},
    {'key': 'temperature', 'label': 'Temperatura'},
    {'key': 'glycemia', 'label': 'Glicemia'},
    {'key': 'capillary_refill_time', 'label': 'Tempo de Preenchimento Capilar (seg)'}, // Text na UI, mas se tentar parsear numérico, plota o gráfico
    {'key': 'body_condition_score', 'label': 'Escore de Condição Corporal (ECC)'},
    {'key': 'abdominal_circ', 'label': 'Circunferência Abdominal'},
    {'key': 'neck_circ', 'label': 'Circunferência do Pescoço'},
    {'key': 'height_withers', 'label': 'Altura na Cernelha'},
    {'key': 'water_intake', 'label': 'Ingestão Hídrica'},
    {'key': 'urine_density', 'label': 'Densidade Urinária'},
    {'key': 'distance_traveled', 'label': 'Distância Percorrida'},
    {'key': 'average_speed', 'label': 'Velocidade Média'},
    {'key': 'sleep_time', 'label': 'Tempo de Sono/Repouso (horas)'},
    {'key': 'stand_latency', 'label': 'Latência para Levantar (segundos)'},
  ];

  static Map<String, List<pw.Widget>> _buildCharts(List<PetEvent> events, PdfColor accentColor, AppLocalizations l10n) {
    final Map<String, List<pw.Widget>> chartsMap = {};

    for (final def in _metricDefinitions) {
      final key = def['key'] as String;
      final label = def['label'] as String;

      // Filtrar eventos que possuam esta métrica válida (conversivel para número)
      final validEvents = events.where((e) {
        final val = e.metrics?[key];
        if (val == null) return false;
        // Permite virgula ou ponto
        return double.tryParse(val.toString().replaceAll(',', '.')) != null;
      }).toList();

      if (validEvents.isNotEmpty) {
        // Ordena cronologicamente
        validEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        final dataSet = <pw.PointChartValue>[];
        double minVal = double.infinity;
        double maxVal = double.negativeInfinity;

        // Converter para pw.PointChartValue (X inteiro para index, Y como double)
        for (int i = 0; i < validEvents.length; i++) {
          final e = validEvents[i];
          final rawVal = e.metrics![key].toString().replaceAll(',', '.');
          final val = double.parse(rawVal);
          
          if (val < minVal) minVal = val;
          if (val > maxVal) maxVal = val;

          dataSet.add(pw.PointChartValue(i.toDouble(), val));
        }
        
        // Evita divisão por zero
        if (minVal == maxVal) {
           minVal -= 1;
           maxVal += 1; 
        }

        // Extensão de Y para dar margem visual no gráfico
        final yRange = maxVal - minVal;
        
        final chartWidget = pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                 children: [
                    pw.Text('• ', style: pw.TextStyle(color: accentColor, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(label, style: pw.TextStyle(color: _colorText, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                 ]
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 160,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  color: _colorCardBg,
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints == null) return pw.SizedBox();
                    
                    final width = constraints.biggest.x;
                    final height = constraints.biggest.y - 20; // Reserva espaço para labels de data
                    
                    // Calcular posições dos pontos
                    final points = <PdfPoint>[];
                    for (int i = 0; i < validEvents.length; i++) {
                      final e = validEvents[i];
                      final val = double.parse(e.metrics![key].toString().replaceAll(',', '.'));
                      // X distribui no espaço. Se tiver só 1, no meio.
                      final x = validEvents.length <= 1 
                          ? width / 2 
                          : (i / (validEvents.length - 1)) * width;
                      // Y é a proporção. O eixo começa no bottom (0) até o height
                      final y = yRange == 0 
                          ? height / 2 
                          : ((val - minVal) / yRange) * (height * 0.8) + (height * 0.1); // 10% de margem top/bottom
                          
                      points.add(PdfPoint(x, y));
                    }

                    return pw.Stack(
                      children: [
                        // Grid horizontal
                        ...List.generate(4, (i) {
                           final yPos = (i / 3) * height; // Bottom, 33%, 66%, Top
                           return pw.Positioned(
                             left: 0,
                             right: 0,
                             bottom: yPos + 20, // +20 por causa do sub-eixo
                             child: pw.Container(height: 1, color: PdfColors.grey200),
                           );
                        }),
                        
                        // O Gráfico Moderno (Preenchimento, Linha, Bolinhas)
                        pw.Positioned(
                          left: 0, right: 0, top: 0, bottom: 20,
                          child: pw.CustomPaint(
                            size: PdfPoint(width, height),
                            painter: (canvas, size) {
                              if (points.isEmpty) return;
                              // 2. Linha Principal do Gráfico
                              canvas.setStrokeColor(accentColor);
                              canvas.setLineWidth(2.5); // Linha mais robusta
                              canvas.setLineCap(PdfLineCap.round);
                              canvas.setLineJoin(PdfLineJoin.round);
                              
                              canvas.moveTo(points.first.x, points.first.y);
                              for (int i = 1; i < points.length; i++) {
                                 // Pode-se implementar curva de Bezier aqui no futuro (curveTo), mas lineTo é bem limpo 
                                 canvas.lineTo(points[i].x, points[i].y);
                              }
                              canvas.strokePath();

                              // 3. Pontos de Dados (Bolinhas)
                              canvas.setFillColor(PdfColors.white); // Miolo branco moderno
                              for (final p in points) {
                                 canvas.setStrokeColor(accentColor);
                                 canvas.setLineWidth(2);
                                 canvas.drawEllipse(p.x, p.y, 4, 4); // Círculo externo
                                 canvas.fillPath();
                                 canvas.drawEllipse(p.x, p.y, 4, 4); // Contorno colorido
                                 canvas.strokePath();
                              }
                            }
                          )
                        ),
                        
                        // Tooltips Flutuantes com os Valores
                        ...List.generate(points.length, (i) {
                           final p = points[i];
                           final val = double.parse(validEvents[i].metrics![key].toString().replaceAll(',', '.'));
                           
                           // Lógica de alinhamento para não cortar nas bordas
                           pw.Alignment alignment = pw.Alignment.bottomCenter;
                           double leftPos = p.x - 20; // Container width = 40, shifted left 20 centers it on p.x
                           
                           if (i == 0 && validEvents.length > 1) {
                              alignment = pw.Alignment.bottomLeft;
                              leftPos = p.x - 2; // Começa próximo ao ponto indo pra direita
                           } else if (i == validEvents.length - 1 && validEvents.length > 1) {
                              alignment = pw.Alignment.bottomRight;
                              leftPos = p.x - 38; // Começa na esquerda indo até o ponto
                           }

                           return pw.Positioned(
                             left: leftPos,
                             bottom: p.y + 24, // Acima da bolinha
                             child: pw.Container(
                               width: 40, // Espaço fixo para o tooltip renderizar
                               alignment: alignment,
                               child: pw.Text(
                                 val.toStringAsFixed(1).replaceAll('.0', ''),
                                 style: pw.TextStyle(color: accentColor, fontSize: 10, fontWeight: pw.FontWeight.bold),
                               ),
                             ),
                           );
                        }),
                        
                        // Eixo X (Datas) fixo na base
                        pw.Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: pw.Row(
                            mainAxisAlignment: validEvents.length == 1 ? pw.MainAxisAlignment.center : pw.MainAxisAlignment.spaceBetween,
                            children: List.generate(validEvents.length, (index) {
                              final eDate = validEvents[index].startDateTime;
                              return pw.Text(
                                DateFormat('dd/MM HH:mm').format(eDate),
                                style: const pw.TextStyle(color: _colorTextDim, fontSize: 8),
                              );
                            })
                          )
                        ),
                      ],
                    );
                  }
                )
              ),
              pw.SizedBox(height: 16),
              // Tabela de Dados abaixo do gráfico
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Data
                  1: const pw.FlexColumnWidth(1), // Hora
                  2: const pw.FlexColumnWidth(1.5), // Valor
                },
                children: [
                  // Cabeçalho da Tabela
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(l10n.agenda_field_date, style: pw.TextStyle(color: _colorTextDim, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(l10n.agenda_field_time, style: pw.TextStyle(color: _colorTextDim, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(l10n.pet_metric_pdf_table_value, style: pw.TextStyle(color: _colorTextDim, fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Linhas da Tabela (inversamente ordenadas, do mais recente para o mais antigo)
                  ...validEvents.reversed.map((e) {
                    final eDate = e.startDateTime;
                    final val = double.parse(e.metrics![key].toString().replaceAll(',', '.'));
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(DateFormat('dd/MM/yyyy').format(eDate), style: const pw.TextStyle(color: _colorText, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(DateFormat('HH:mm').format(eDate), style: const pw.TextStyle(color: _colorText, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            val.toStringAsFixed(1).replaceAll('.0', ''),
                            style: pw.TextStyle(color: accentColor, fontSize: 10, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ]
          )
        );
        chartsMap[key] = [chartWidget];
      }
    }
    return chartsMap;
  }
}
