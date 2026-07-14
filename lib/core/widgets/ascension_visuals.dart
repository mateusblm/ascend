import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Representa o patamar pessoal a partir do nivel, sem componente competitivo.
enum PatamarPessoal {
  f('F', 'Iniciante', 1),
  e('E', 'Explorador', 5),
  d('D', 'Praticante', 10),
  c('C', 'Constante', 20),
  b('B', 'Veterano', 35),
  a('A', 'Referência', 55),
  s('S', 'Ascendente', 80);

  const PatamarPessoal(this.sigla, this.titulo, this.nivelMinimo);

  final String sigla;
  final String titulo;
  final int nivelMinimo;

  /// Determina a leitura visual de progresso sem gravar um rank no perfil.
  static PatamarPessoal paraNivel(int nivel) {
    return PatamarPessoal.values.lastWhere(
      (patamar) => nivel >= patamar.nivelMinimo,
      orElse: () => PatamarPessoal.f,
    );
  }
}

/// Glifo original da Ascensão: linha vertical, corte diagonal e três marcos.
class GlifoAscensao extends StatelessWidget {
  const GlifoAscensao({
    super.key,
    this.tamanho = 28,
    this.cor = AppColors.ascension,
  });

  final double tamanho;
  final Color cor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: tamanho,
    height: tamanho,
    child: CustomPaint(painter: _GlifoAscensaoPainter(cor)),
  );
}

class _GlifoAscensaoPainter extends CustomPainter {
  const _GlifoAscensaoPainter(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.square;
    final x = size.width * .5;
    canvas.drawLine(
      Offset(x, size.height * .1),
      Offset(x, size.height * .9),
      linha,
    );
    canvas.drawLine(
      Offset(size.width * .23, size.height * .67),
      Offset(size.width * .77, size.height * .31),
      linha,
    );
    for (final y in [0.2, 0.5, 0.8]) {
      canvas.drawCircle(
        Offset(x, size.height * y),
        size.width * .075,
        Paint()..color = cor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlifoAscensaoPainter oldDelegate) =>
      oldDelegate.cor != cor;
}

/// Marca a continuidade entre missões e marcos de uma rota pessoal.
class EixoAscensao extends StatelessWidget {
  const EixoAscensao({
    super.key,
    required this.cor,
    this.concluido = false,
    this.altura = 72,
  });

  final Color cor;
  final bool concluido;
  final double altura;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: altura,
    child: CustomPaint(painter: _EixoAscensaoPainter(cor, concluido)),
  );
}

class _EixoAscensaoPainter extends CustomPainter {
  const _EixoAscensaoPainter(this.cor, this.concluido);
  final Color cor;
  final bool concluido;

  @override
  void paint(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = cor.withValues(alpha: concluido ? .7 : .35)
      ..strokeWidth = 1.2;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), linha);
    final marcador = Paint()
      ..color = concluido ? cor : AppColors.surfaceStrong
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, size.height * .32), 6, marcador);
    canvas.drawCircle(
      Offset(x, size.height * .32),
      6,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    if (concluido) {
      final check = Paint()
        ..color = AppColors.background
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x - 2.5, size.height * .32),
        Offset(x - .5, size.height * .32 + 2),
        check,
      );
      canvas.drawLine(
        Offset(x - .5, size.height * .32 + 2),
        Offset(x + 3, size.height * .32 - 2),
        check,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EixoAscensaoPainter oldDelegate) =>
      oldDelegate.cor != cor || oldDelegate.concluido != concluido;
}
