import 'package:ascend/core/config/release_contact_config.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/focus_selection_sheet.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final authState = ref.watch(authProvider);
    final authProfile = authState is AuthSuccess ? authState : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevealBlock(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'CONTA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const RevealBlock(
                delay: Duration(milliseconds: 60),
                child: Text(
                  'Ajuste os dados basicos do jogador, veja a conta conectada e controle a sessao atual.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RevealBlock(
                delay: const Duration(milliseconds: 120),
                child: _AccountPanel(
                  child: Row(
                    children: [
                      _AccountAvatar(photoUrl: authProfile?.photoUrl ?? ''),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              player.primaryFocus.label,
                              style: const TextStyle(
                                color: AppColors.neonBlue,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              authProfile?.email ?? 'Conta Google conectada',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 180),
                child: _AccountPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERFIL',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingRow(
                        label: 'Nome do jogador',
                        value: player.name,
                        actionLabel: 'EDITAR',
                        onPressed: () => _editPlayerName(context, player),
                      ),
                      const SizedBox(height: 12),
                      _SettingRow(
                        label: 'Foco principal',
                        value: player.primaryFocus.label,
                        helper:
                            'Muda a direcao do kit inicial e das sugestoes daqui para frente.',
                        actionLabel: 'ALTERAR',
                        onPressed: () => _openFocusSelectionSheet(
                          context,
                          player.primaryFocus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 240),
                child: _AccountPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONTA CONECTADA',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoLine(
                        label: 'Provedor',
                        value: authProfile == null ? 'Nenhum' : 'Google',
                      ),
                      const SizedBox(height: 10),
                      _InfoLine(
                        label: 'Email',
                        value: authProfile?.email ?? 'Nao disponivel',
                      ),
                      const SizedBox(height: 10),
                      _InfoLine(
                        label: 'UID',
                        value: authProfile?.uid ?? 'Nao autenticado',
                        subtle: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 300),
                child: _AccountPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIVACIDADE E TERMOS',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'A base de privacidade, uso e responsabilidade do produto ja esta definida e pode ser consultada dentro do app enquanto os links publicos nao entram.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openPolicyDialog(
                                context,
                                title: 'Politica de privacidade',
                                content: _privacyPolicySummary,
                              ),
                              child: const Text('PRIVACIDADE'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openPolicyDialog(
                                context,
                                title: 'Termos de uso',
                                content: _termsOfUseSummary,
                              ),
                              child: const Text('TERMOS'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 360),
                child: _AccountPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUPORTE E DADOS',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _InfoLine(
                        label: ReleaseContactConfig.supportChannelLabel,
                        value: ReleaseContactConfig.supportEmail,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ReleaseContactConfig.usesPlaceholderSupport
                            ? 'Substitua esse inbox por um canal real antes de distribuir o app fora do teste controlado.'
                            : 'Canal configurado para a release atual. Confirme monitoramento ativo antes de ampliar a distribuicao.',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11.8,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingRow(
                        label: 'Exclusao de conta e dados',
                        value: 'Pedido manual com revisao operacional',
                        helper:
                            'O processo atual cobre remocao de acesso e limpeza dos dados remotos usados pelo app.',
                        actionLabel: 'COMO FUNCIONA',
                        onPressed: () => _openPolicyDialog(
                          context,
                          title: 'Exclusao de conta e dados',
                          content: _accountDeletionSummary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 420),
                child: _AccountPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SESSAO',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Este e o lugar para logout, futuras configuracoes de privacidade e gestao de conta.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: authProfile == null || _isSigningOut
                              ? null
                              : () => _handleSignOut(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _isSigningOut
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.redAccent,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded),
                          label: Text(
                            _isSigningOut ? 'SAINDO...' : 'SAIR DA CONTA',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editPlayerName(BuildContext context, Player player) async {
    final controller = TextEditingController(text: player.name);
    final messenger = ScaffoldMessenger.of(context);
    final nextName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Alterar nome'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              hintText: 'Como voce quer aparecer no app?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted || nextName == null) return;

    final trimmed = nextName.trim();
    if (trimmed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('O nome nao pode ficar vazio.')),
      );
      return;
    }

    ref.read(playerProvider.notifier).updateName(trimmed);
    messenger.showSnackBar(
      const SnackBar(content: Text('Nome do jogador atualizado.')),
    );
  }

  void _openFocusSelectionSheet(
    BuildContext context,
    AwakeningPath currentFocus,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FocusSelectionSheet(currentFocus: currentFocus),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel sair da conta agora.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  Future<void> _openPolicyDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.8,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('FECHAR'),
            ),
          ],
        );
      },
    );
  }
}

const String _privacyPolicySummary =
    'Ascend coleta somente os dados necessarios para autenticacao, progresso do jogador, quests, estado competitivo, analytics operacionais e erros de execucao. '
    'O objetivo e operar o produto, medir o funil principal e proteger a integridade competitiva. '
    'O app nao deve vender dados pessoais. Dados de analytics e crash podem ser usados para diagnostico, estabilidade e melhoria de produto. '
    'O usuario pode solicitar revisao ou exclusao dos dados operacionais pelos canais de suporte definidos pela release.';

const String _termsOfUseSummary =
    'Ascend e um produto de progressao pessoal com camadas competitivas e regras de integridade. '
    'O usuario e responsavel pelas informacoes que registra, pelo uso da propria conta Google e pelo respeito ao uso honesto das mecanicas competitivas. '
    'O app pode ajustar regras, temporadas, recompensas, verificacoes e politicas operacionais para manter estabilidade, seguranca e equilibrio de produto. '
    'Abuso competitivo, manipulacao de fluxo ou exploracao deliberada podem gerar revisao operacional e perda de standing competitivo.';

const String _accountDeletionSummary =
    'Durante a fase atual, pedidos de exclusao devem ser tratados manualmente. '
    'O fluxo minimo esperado e: confirmar a identidade do titular, registrar o pedido, remover o acesso autenticado quando aplicavel e limpar os dados remotos vinculados ao usuario usados pelo app. '
    'Colecoes de leitura competitiva, season state e demais registros operacionais devem ser revisados no mesmo processo. '
    'Antes de beta publica ou distribuicao aberta, esse fluxo precisa apontar para um canal real de suporte e uma politica publica de prazo de atendimento.';

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neonBlue.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.28)),
        image: photoUrl.isEmpty
            ? null
            : DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover),
      ),
      child: photoUrl.isEmpty
          ? const Icon(
              Icons.manage_accounts_rounded,
              color: AppColors.neonBlue,
              size: 30,
            )
          : null,
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
    this.helper,
  });

  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onPressed;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (helper != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    helper!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: AppColors.neonBlue,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.subtle = false,
  });

  final String label;
  final String value;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11.5,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            color: subtle ? Colors.white60 : Colors.white,
            fontSize: subtle ? 12.2 : 14.2,
            fontWeight: subtle ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
