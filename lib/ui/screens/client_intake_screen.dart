import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../widgets/giles_lens.dart';
import '../widgets/praxis_button.dart';

class ClientIntakeScreen extends ConsumerStatefulWidget {
  const ClientIntakeScreen({super.key});

  @override
  ConsumerState<ClientIntakeScreen> createState() => _ClientIntakeScreenState();
}

class _ClientIntakeScreenState extends ConsumerState<ClientIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _orgController = TextEditingController();
  final _challengeController = TextEditingController();
  final _referralController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _orgController.dispose();
    _challengeController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submitIntake() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (mounted) {
        context.push('/contract', extra: {
          'name': _nameController.text.trim(),
          'challenge': _challengeController.text.trim(),
          // In a real app we'd pass everything, but sticking to the critical path
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PraxisTheme.creamVellum,
      appBar: AppBar(
        leading: const BackButton(color: PraxisTheme.charcoalInk),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E5E5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        const GilesLens(state: GilesState.idle, size: 40),
                        const SizedBox(height: 24),
                        Text(
                          "EXECUTIVE INTAKE",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "The Velvet Rope",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: PraxisTheme.charcoalInk.withAlpha(100),
                            fontSize: 10,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 56),

                  // 1. Identity
                  Text(
                    "I. IDENTITY",
                    style: _sectionHeaderStyle(context),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _roleController,
                          label: "Current Role",
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildTextField(
                          controller: _orgController,
                          label: "Organization",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 2. Context
                  Text(
                    "II. CONTEXT",
                    style: _sectionHeaderStyle(context),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _challengeController,
                    label: "Primary Strategic Challenge",
                    maxLines: 5,
                    hint: "Describe the core conflict, decision, or transition you are facing...",
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _referralController,
                    label: "Referral Source (Optional)",
                  ),

                  const SizedBox(height: 64),

                  // Submit
                  PraxisButton(
                    onPressed: _isSubmitting ? null : _submitIntake,
                    backgroundColor: PraxisTheme.charcoalInk,
                    foregroundColor: PraxisTheme.creamVellum,
                    isLoading: _isSubmitting,
                    child: const Text("REVIEW CONTRACT"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle? _sectionHeaderStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: PraxisTheme.burnishedGold,
        );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: PraxisTheme.charcoalInk.withAlpha(80),
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.zero,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: PraxisTheme.charcoalInk),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ],
    );
  }
}
