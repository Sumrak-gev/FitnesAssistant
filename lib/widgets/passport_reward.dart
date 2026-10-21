import 'package:flutter/material.dart';

/// External community link unlocked at the strong stage of progress.
class PassportReward extends StatelessWidget {
  const PassportReward({super.key, required this.level, required this.onOpen});

  final int level;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final unlocked = level >= 6;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: unlocked ? onOpen : null,
        child: Row(
          children: [
            Opacity(
              opacity: unlocked ? 1 : .5,
              child: Image.asset(
                'assets/israel-passport-joke.png',
                width: 112,
                height: 144,
                fit: BoxFit.cover,
                semanticLabel: 'Изображение награды шестого уровня',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unlocked ? 'Награда открыта' : 'Награда 6-го уровня',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: scheme.primary),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Получить паспорт Израиля',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unlocked
                          ? 'Помощь с получением · Telegram-канал ↗'
                          : 'Откроется на уровне 6 · Силач',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
