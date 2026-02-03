import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';
import '../models/session_model.dart' as app_models;
import '../utils/constants.dart';
import 'giles_service.dart';

// Providers
final gilesServiceProvider = Provider((ref) => GilesService(apiKey: AppConstants.geminiApiKey));

final praxisRepositoryProvider = Provider((ref) {
  return PraxisRepository(giles: ref.watch(gilesServiceProvider));
});

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  return ref.watch(praxisRepositoryProvider).getClients();
});

final sessionsProvider = FutureProviderFamily<List<app_models.Session>, String>((ref, clientId) async {
  return ref.watch(praxisRepositoryProvider).getSessions(clientId);
});

class PraxisRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final GilesService _giles;

  PraxisRepository({required GilesService giles}) : _giles = giles;

  Future<List<Client>> getClients() async {
    final response = await _client
        .from('clients')
        .select()
        .order('created_at', ascending: false);
    
    // select() returns List<Map<String, dynamic>>
    final data = response as List<dynamic>;
    return data.map((json) => Client.fromJson(json)).toList();
  }

  Future<List<app_models.Session>> getSessions(String clientId) async {
    final response = await _client
        .from('sessions')
        .select()
        .eq('client_id', clientId)
        .order('scheduled_at', ascending: true);

    final data = response as List<dynamic>;
    return data.map((json) => app_models.Session.fromJson(json)).toList();
  }

  Future<void> createClient({
    required String fullName,
    required String organization,
    required String challenge,
    String? referral,
  }) async {
    final userId = _client.auth.currentUser!.id;
    
    // Check if tenant record exists, if not create it (One time setup for new users)
    final tenantCheck = await _client.from('tenants').select().eq('id', userId);
    if ((tenantCheck as List).isEmpty) {
       await _client.from('tenants').insert({'id': userId});
    }

    await _client.from('clients').insert({
      'tenant_id': userId,
      'full_name': fullName,
      'organization': organization,
      'created_at': DateTime.now().toIso8601String(),
      // We store the challenge in psychometrics for now, or could add a 'notes' column
      'psychometrics_json': {
        'initial_challenge': challenge,
        'referral': referral,
      }
    });

    // 2. Generate Initial Briefing with GILES
    // We fetch the newly created client to get the ID, or we just trust the flow? 
    // Supabase insert select isn't default in flutter sdk simple insert.
    // Let's query the specific client we just made (unsafe if duplicates, but okay for MVP)
    final newClientRes = await _client
        .from('clients')
        .select()
        .eq('full_name', fullName)
        .order('created_at', ascending: false)
        .limit(1)
        .single();
    
    final clientId = newClientRes['id'] as String;

    // Ask GILES for the briefing
    final prompt = """
    NEW CLIENT INTAKE:
    Name: $fullName
    Role: ${newClientRes['organization'] ?? 'Unknown'}
    Strategic Challenge: "$challenge"

    TASK: Draft the initial "Briefing Note" for the intake session. 
    Analyze the challenge for hidden conflicts. Structure: Context, Key Conflicts, Required Actions.
    """;

    final briefingNote = await _giles.generateBriefing(prompt) ?? "Giles is offline.";

    // 3. Create the "Intake Session"
    await _client.from('sessions').insert({
      'client_id': clientId,
      'status': 'scheduled',
      'scheduled_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(), // Tomorrow
      'briefing_note_md': briefingNote,
    });
  }
}
