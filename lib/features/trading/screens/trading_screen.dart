import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;


class WatchlistItem {
  final String symbol;
  final String exchange; // 'BSE' or 'NSE'
  WatchlistItem({required this.symbol, required this.exchange});
}

final watchlistProvider = StateProvider<List<WatchlistItem>>((ref) => [
  WatchlistItem(symbol: 'UNIONBANK', exchange: 'BSE'),
]);

final alphaVantageApiKey = 'LSSBUCDFL2QMC3H0';


final alphaVantageProvider = FutureProvider.family<Map<String, dynamic>, WatchlistItem>((ref, item) async {
  final url = Uri.parse(
    'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${item.symbol}.${item.exchange}&apikey=$alphaVantageApiKey'
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final quote = data['Global Quote'] as Map<String, dynamic>?;
    if (quote == null || quote.isEmpty) {
      throw Exception('No data for ${item.symbol}');
    }
    return quote;
  } else {
    throw Exception('Failed to fetch data for ${item.symbol}');
  }
});


class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> {
  final _symbolController = TextEditingController();
  String _selectedExchange = 'BSE';

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  void _addToWatchlist() {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;
    final item = WatchlistItem(symbol: symbol, exchange: _selectedExchange);
    final watchlist = ref.read(watchlistProvider.notifier).state;
    // Prevent duplicates
    if (!watchlist.any((w) => w.symbol == item.symbol && w.exchange == item.exchange)) {
      ref.read(watchlistProvider.notifier).state = [item, ...watchlist];
    }
    _symbolController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading & Watchlist'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Symbol',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addToWatchlist(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedExchange,
                  items: const [
                    DropdownMenuItem(value: 'BSE', child: Text('BSE')),
                    DropdownMenuItem(value: 'NSE', child: Text('NSE')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedExchange = val);
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addToWatchlist,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: watchlist.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = watchlist[index];
                return _LiveQuoteTile(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _LiveQuoteTile extends ConsumerWidget {
  final WatchlistItem item;
  const _LiveQuoteTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(alphaVantageProvider(item));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: quoteAsync.when(
          data: (data) {
            final price = data['05. price'] ?? '-';
            final change = double.tryParse(data['09. change']?.toString().replaceAll(',', '') ?? '0') ?? 0.0;
            final percentRaw = data['10. change percent']?.toString() ?? '0%';
            final percentStr = percentRaw.replaceAll('%', '').replaceAll(' ', '');
            final percent = double.tryParse(percentStr) ?? 0.0;
            final Color color = change >= 0.0 ? Colors.green : Colors.red;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.symbol, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(item.exchange, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹$price', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${change >= 0.0 ? '+' : ''}${change.toStringAsFixed(2)}  (${percent.toStringAsFixed(2)}%)',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
