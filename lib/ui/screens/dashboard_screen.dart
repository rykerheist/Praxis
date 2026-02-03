import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:praxis/models/client_model.dart';
import 'package:praxis/services/praxis_repository.dart';
import 'package:praxis/ui/modules/dossier/dossier_view.dart';
import '../../theme.dart';
import '../widgets/giles_lens.dart';
import '../widgets/praxis_logo.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  GilesState _gilesState = GilesState.idle;

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: PraxisTheme.creamVellum,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           context.push('/intake');
        },
        backgroundColor: PraxisTheme.charcoalInk,
        foregroundColor: PraxisTheme.creamVellum,
        label: const Text("INTAKE"),
        icon: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          // 1. Sidebar
          Container(
            width: 80,
            color: Colors.white.withAlpha(20), // Subtle separation
            child: Column(
              children: [
                const SizedBox(height: 48),
                // GILES resides here or in the header. 
                GestureDetector(
                  onTap: () {
                    // Toggle states for demo
                    setState(() {
                      if (_gilesState == GilesState.idle) {
                        _gilesState = GilesState.thinking;
                      } else if (_gilesState == GilesState.thinking) {
                        _gilesState = GilesState.speaking;
                      } else {
                        _gilesState = GilesState.idle;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: GilesLens(state: _gilesState, size: 32),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // 2. Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const PraxisLogo(),
                      // Status Indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "GILES System: ONLINE",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 2.0,
                            color: PraxisTheme.charcoalInk.withAlpha(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // The Dossier Folder View
                  Expanded(
                    child: clientsAsync.when(
                      data: (clients) {
                        if (clients.isEmpty) {
                          return Center(
                            child: Text(
                              "No dossiers found. Initiate INTAKE.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: PraxisTheme.charcoalInk.withAlpha(150),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }

                        return Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: clients.map((client) {
                                // For now, we load sessions for each client individually 
                                // In a real app we might optimize this or load on demand
                                return _ClientDossierWrapper(client: client);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: PraxisTheme.charcoalInk),
                      ),
                      error: (err, stack) => Center(
                        child: Text("Error loading data: $err"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientDossierWrapper extends ConsumerWidget {
  final Client client;

  const _ClientDossierWrapper({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider(client.id));

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: sessionsAsync.when(
        data: (sessions) {
          // Find the next scheduled session or the latest one
          final nextSession = sessions.isNotEmpty ? sessions.first : null;
          return DossierView(
            client: client,
            nextSession: nextSession,
          );
        },
        loading: () => const SizedBox(
          width: 600,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(
          width: 600,
          child: Center(child: Text("Error loading session data")),
        ),
      ),
    );
  }
}
