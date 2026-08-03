import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/nav_guard.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/inter_season_controller.dart';
import '../application/inter_season_data_providers.dart';
import '../model/transfer_offer.dart';
import '../data/inter_season_repository.dart';
import 'widgets/base_investment_form.dart';
import 'widgets/incoming_offers_list.dart';
import 'widgets/my_pilots_list.dart';
import 'widgets/principal_hire_list.dart';
import 'widgets/transfer_list.dart';

class InterSeasonScreen extends ConsumerStatefulWidget {
  const InterSeasonScreen({super.key});
  @override
  ConsumerState<InterSeasonScreen> createState() => _InterSeasonScreenState();
}

class _InterSeasonScreenState extends ConsumerState<InterSeasonScreen> {
  int? _respondingTo;

  /// Ответ на предложение идёт обычным HTTP-запросом: предложение хранится
  /// на сервере, поэтому отвечать можно когда угодно, а не только пока
  /// покупатель ждёт на линии.
  Future<void> _respond(TransferOffer offer, bool accept) async {
    setState(() => _respondingTo = offer.id);
    try {
      await ref
          .read(interSeasonRepositoryProvider)
          .respondToOffer(offerId: offer.id, accept: accept);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accept ? 'Трансфер принят' : 'Предложение отклонено')),
      );
      ref.invalidate(incomingOffersProvider);
      ref.invalidate(myTeamProvider);
      ref.invalidate(interSeasonBudgetProvider);
      ref.invalidate(freePilotsProvider);
      ref.invalidate(ownedPilotsProvider);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _respondingTo = null);
    }
  }

  Future<void> _act(Future<void> Function() action, String ok) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok)));
      ref.invalidate(myTeamProvider);
      ref.invalidate(interSeasonBudgetProvider);
      ref.invalidate(freePilotsProvider);
      ref.invalidate(ownedPilotsProvider);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(interSeasonControllerProvider, (prev, next) {
      if (next.seasonStarted && (prev?.seasonStarted != true)) {
        if (isCurrentLocation(context, '/inter-season')) context.go('/token-setup');
      }
      if (next.error != null && prev?.error != next.error) {
        showErrorSnackbar(context, next.error!);
        ref.read(interSeasonControllerProvider.notifier).clearError();
      }
    });

    final repo = ref.read(interSeasonRepositoryProvider);
    final myTeam = ref.watch(myTeamProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Межсезонье'),
          actions: [
            Consumer(builder: (_, r, __) {
              final budget = r.watch(interSeasonBudgetProvider).valueOrNull;
              if (budget == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text('💰 ${budget.budget} · 🎟 ${budget.tokens}'),
                ),
              );
            }),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Трансферы'),
            Tab(text: 'Руководитель'),
            Tab(text: 'База'),
            Tab(text: 'Готовность'),
          ]),
        ),
        body: TabBarView(
          children: [
            // Transfers: my roster + free agents + other players' pilots
            Consumer(builder: (_, r, __) {
              final free = r.watch(freePilotsProvider);
              final owned = r.watch(ownedPilotsProvider);
              return AsyncValueView(
                value: myTeam,
                data: (t) => ListView(
                  children: [
                    // Входящие предложения — первым блоком: это единственное,
                    // что требует реакции игрока прямо сейчас.
                    Consumer(builder: (_, r2, __) {
                      final offers =
                          r2.watch(incomingOffersProvider).valueOrNull ??
                              const <TransferOffer>[];
                      if (offers.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text('Предложения по вашим пилотам',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IncomingOffersList(
                            offers: offers,
                            busyOfferId: _respondingTo,
                            onRespond: _respond,
                          ),
                        ],
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Мои пилоты', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    MyPilotsList(
                      pilots: [t.pilot1, t.pilot2],
                      onFire: (p) =>
                          _act(() => repo.fire(who: 'pilot', id: p.id), 'Пилот уволен'),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Свободные агенты', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    AsyncValueView(
                      value: free,
                      data: (pilots) => TransferList(
                        pilots: pilots,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onBuy: (p, price) =>
                            _act(() => repo.buyPilot(pilotId: p.id, price: price), 'Куплено'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Пилоты других игроков',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    AsyncValueView(
                      value: owned,
                      data: (pilots) => TransferList(
                        pilots: pilots,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onBuy: (p, price) => _act(
                            () => repo.buyPilot(pilotId: p.id, price: price), 'Предложение отправлено'),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Principal hire/fire (gated on myTeam so the current principal's
            // Hire/Fire label doesn't flicker while myTeam is still loading)
            Consumer(builder: (_, r, __) {
              final principals = r.watch(interSeasonPrincipalsProvider);
              return AsyncValueView(
                value: myTeam,
                data: (t) => AsyncValueView(
                  value: principals,
                  data: (list) => PrincipalHireList(
                    principals: list,
                    currentPrincipalId: t.principal.id,
                    onHire: (p) => _act(
                        () => repo.hirePrincipal(principalId: p.id, price: p.price), 'Нанят'),
                    onFire: (p) => _act(() => repo.fire(who: 'principal', id: p.id), 'Уволен'),
                  ),
                ),
              );
            }),
            // Base sliders
            AsyncValueView(
              value: myTeam,
              data: (t) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: BaseInvestmentForm(
                  initial: t.team,
                  onSubmit: ({required base, required engineer, required tube, required sim}) => _act(
                    () => repo.updateBase(base: base, engineer: engineer, tube: tube, sim: sim),
                    'Base updated',
                  ),
                ),
              ),
            ),
            // Ready
            Center(
              child: Consumer(builder: (_, r, __) {
                final st = r.watch(interSeasonControllerProvider);
                return FilledButton(
                  onPressed: st.ready || st.busy
                      ? null
                      : () => r.read(interSeasonControllerProvider.notifier).markReady(),
                  child: Text(st.ready ? 'Ожидаем других игроков…' : 'Готов к новому сезону'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
