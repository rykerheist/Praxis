import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:praxis/models/client_model.dart';
import 'package:praxis/models/session_model.dart';
import '../../widgets/praxis_button.dart';
import '../../../theme.dart';

class DossierView extends StatelessWidget {
  final Client client;
  final Session? nextSession;

  const DossierView({
    super.key,
    required this.client,
    this.nextSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600, // Fixed width for the "Folder" feel
      margin: const EdgeInsets.only(top: 24, bottom: 24, right: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Folder Tab Header
          Row(
            children: [
              Container(
                height: 40,
                width: 200,
                decoration: const BoxDecoration(
                  color: PraxisTheme.burnishedGold,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    topLeft: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "CONFIDENTIAL",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
              ),
              const Spacer(),
              // Action Button if Session exists
              if (nextSession != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: PraxisButton(
                    width: 160,
                    height: 40,
                    backgroundColor: Colors.transparent,
                    foregroundColor: PraxisTheme.charcoalInk,
                    onPressed: () {
                      context.push('/session/${nextSession!.id}');
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(Icons.login, size: 16, color: PraxisTheme.charcoalInk),
                         SizedBox(width: 8),
                         Text("ENTER ROOM"),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        client.fullName,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          client.organization?.toUpperCase() ?? "",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: PraxisTheme.charcoalInk.withAlpha(150),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, height: 48),

                  // The Briefing Card
                  if (nextSession?.briefingNoteMd != null) ...[
                    Text(
                      "SESSION BRIEFING",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PraxisTheme.charcoalInk.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: MarkdownBody(
                        data: nextSession!.briefingNoteMd!,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: Theme.of(context).textTheme.bodyMedium,
                          strong: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],

                  // Session History (Timeline)
                  Text(
                    "SESSION HISTORY",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PraxisTheme.charcoalInk.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        // The Axis Line
                        Positioned(
                          left: 20,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 1,
                            color: const Color(0xFFE5E5E5),
                          ),
                        ),
                        // List would go here (Dummy for now)
                        ListView(
                          children: [
                            _buildTimelineItem(context, "Initial Assessment", "2 weeks ago"),
                            _buildTimelineItem(context, "Hogan Debrief", "1 month ago"),
                          ],
                        ),
                      ],
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

  Widget _buildTimelineItem(BuildContext context, String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: PraxisTheme.charcoalInk,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PraxisTheme.charcoalInk.withAlpha(120),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
