import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../application/inter_season_controller.dart';
import '../application/inter_season_data_providers.dart';
import '../data/inter_season_repository.dart';
import 'widgets/base_investment_form.dart';
import 'widgets/incoming_offer_dialog.dart';
import 'widgets/principal_hire_list.dart';
import 'widgets/transfer_list.dart';

class InterSeasonScreen extends ConsumerStatefulWidget {
  const InterSeasonScreen({super.key});
  @override
  ConsumerState<InterSeasonScreen> createState() => _InterSeasonScreenState();
}

class _InterSeasonScreenState extends ConsumerState<InterSeasonScreen> {
  bool _dialogOpen = false;

  Future<void> _drainOffers() async {
    if (_dialogOpen) return;
    final offers = ref.read(interSeasonControllerProvider).incomingOffers;
    if (offers.isEmpty) return;
    _dialogOpen = true;
    final offer = offers.first;
    final accept = await showIncomingOfferDialog(context, offer);
    _dialogOpen = false;
    if (accept != null) {
      ref.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: accept);
    } else {
      // dismissed → decline so the queue drains
      ref.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: false);
    }
    if (mounted) _drainOffers();
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
      if (next.incomingOffers.isNotEmpty) _drainOffers();
      if (next.seasonStarted && (prev?.seasonStarted != true)) {
        context.go('/token-setup');
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
          title: const Text('Inter-Season'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Transfers'),
            Tab(text: 'Principal'),
            Tab(text: 'Base'),
            Tab(text: 'Ready'),
          ]),
        ),
        body: TabBarView(
          children: [
            // Transfers: free pilots
            Consumer(builder: (_, r, __) {
              final free = r.watch(freePilotsProvider);
              return AsyncValueView(
                value: free,
                data: (pilots) => TransferList(
                  pilots: pilots,
                  onBuy: (p, price) =>
                      _act(() => repo.buyPilot(pilotId: p.id, price: price), 'Offer sent'),
                ),
              );
            }),
            // Principal hire/fire
            Consumer(builder: (_, r, __) {
              final principals = r.watch(interSeasonPrincipalsProvider);
              return AsyncValueView(
                value: principals,
                data: (list) => PrincipalHireList(
                  principals: list,
                  currentPrincipalId: myTeam.valueOrNull?.principal.id,
                  onHire: (p) =>
                      _act(() => repo.hirePrincipal(principalId: p.id, price: p.price), 'Hired'),
                  onFire: (p) => _act(() => repo.fire(who: 'principal', id: p.id), 'Fired'),
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
                  child: Text(st.ready ? 'Waiting for other players…' : 'Ready for new season'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
