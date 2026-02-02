import 'package:flutter/material.dart';

/// **AppScrollView - Protocolo Master ScanNut 2026**
///
/// Widget de ergonomia avançada projetado para o hardware SM A256E.
/// Utiliza LayoutBuilder e IntrinsicHeight para garantir que o conteúdo
/// expanda para preencher a tela quando pequeno, mas role quando necessário,
/// permitindo o uso de Spacers e evitando overflow de teclado/rodapé.
class AppScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final MainAxisAlignment mainAxisAlignment;

  const AppScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
