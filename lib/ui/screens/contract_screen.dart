import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use 'pw' prefix for PDF widgets
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme.dart';
import '../widgets/praxis_button.dart';
import '../../services/praxis_repository.dart';
import '../widgets/giles_lens.dart';
import 'package:go_router/go_router.dart';

class ContractScreen extends ConsumerStatefulWidget {
  final String clientName;
  final String challenge; // We pass this through context or arguments normally

  const ContractScreen({
    super.key,
    required this.clientName,
    required this.challenge,
  });

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen> {
  final _initialsController = TextEditingController();
  bool _isGenerating = false;
  
  // Hardcoded Legalese for the "Velvet Rope"
  static const String _contractText = """
MEMORANDUM OF UNDERSTANDING

BETWEEN:
PRAXIS CONSULTANCY ("The Firm")
AND THE UNDERSIGNED ("The Principal")

1. OBJECTIVE
The Principal engages The Firm to address the strategic challenge identified during intake. The Firm employs proprietary methodology including, but not limited to, the 'Praxis Dossier' and 'Giles Intelligence System'.

2. CONFIDENTIALITY
All dialogues, transcripts, and psychological profiles are strictly confidential. The Firm utilizes secure, encrypted storage.

3. COMMITMENT
The Principal agrees to full transparency in all sessions. The Firm guarantees candor, no matter how uncomfortable.

4. TERMS
This engagement operates on a retainer basis. Cancellation details are outlined in the full service agreement.

By signing below with initials, you acknowledge these terms.
""";

  Future<void> _signAndSubmit() async {
    if (_initialsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Initials required.")),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // 1. Generate PDF
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.interRegular();
      final titleFont = await PdfGoogleFonts.playfairDisplayBold();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text("PRAXIS", style: pw.TextStyle(font: titleFont, fontSize: 24)),
                ),
                pw.SizedBox(height: 40),
                pw.Text("CLIENT: ${widget.clientName.toUpperCase()}", style: pw.TextStyle(font: font, fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Text("DATE: ${DateTime.now().toString().split(' ')[0]}", style: pw.TextStyle(font: font)),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(_contractText, style: pw.TextStyle(font: font, fontSize: 12, lineSpacing: 5)),
                pw.SizedBox(height: 60),
                pw.Row(
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 100,
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                          child: pw.Text(
                            _initialsController.text.toUpperCase(),
                            style: pw.TextStyle(font: titleFont, fontSize: 18),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text("INITIALS", style: pw.TextStyle(font: font, fontSize: 10)),
                      ],
                    )
                  ],
                ),
              ],
            );
          },
        ),
      );

      // 2. Save/Upload PDF
      // For web support we'd do bytes, but for mobile/desktop we can file
      final Uint8List bytes = await pdf.save();
      
      // Upload to Supabase
      final fileName = 'contract_${widget.clientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Supabase.instance.client.storage
          .from('contracts')
          .uploadBinary(fileName, bytes);

      // 3. Create Client (Now we actually create the client after the contract is signed)
      await ref.read(praxisRepositoryProvider).createClient(
        fullName: widget.clientName,
        organization: "Pending Org", // We'd pass this too if we wanted perfection, simplification for now
        challenge: widget.challenge,
      );

      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dossier initialized.")),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PraxisTheme.creamVellum,
      appBar: AppBar(
        title: const Text("THE AGREEMENT", style: TextStyle(color: PraxisTheme.charcoalInk, fontSize: 14, letterSpacing: 2)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: PraxisTheme.charcoalInk),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 500, // Explicit paper width
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
               BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: GilesLens(state: GilesState.idle, size: 24)),
              const SizedBox(height: 32),
              Text(
                _contractText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.8, fontFamily: 'Courier'), 
                // Using Courier/Monospace for contract feel
              ),
              const SizedBox(height: 48),
              
              // Signature Field
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _initialsController,
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        hintText: "Initials",
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: PraxisTheme.charcoalInk)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: PraxisTheme.burnishedGold, width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text("Sign here to accepted terms"),
                ],
              ),
              const SizedBox(height: 48),

              PraxisButton(
                onPressed: _isGenerating ? null : _signAndSubmit,
                backgroundColor: PraxisTheme.charcoalInk,
                foregroundColor: PraxisTheme.creamVellum,
                isLoading: _isGenerating,
                child: const Text("RATIFY & ENTER"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
