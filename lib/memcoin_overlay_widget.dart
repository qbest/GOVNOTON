import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'constants.dart';  // Импортируем файл с адресом

class MemcoinOverlayWidget extends StatefulWidget {
  final String apiUrl;
  final String memcoinName;
  final String memcoinAmount;
  final String currency;

  const MemcoinOverlayWidget({
    super.key,
    required this.apiUrl,
    required this.memcoinName,
    required this.memcoinAmount,
    this.currency = '^-^',
  });

  @override
  MemcoinOverlayWidgetState createState() => MemcoinOverlayWidgetState();
}

class MemcoinOverlayWidgetState extends State<MemcoinOverlayWidget> {
  double _price = 0.0;
  bool _isLoading = true;
  String _error = '';
  double _percentageChange = 0.0;
  bool _showDonationInfo = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _fetchCoinPrice();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchCoinPrice());
  }

  Future<void> _fetchCoinPrice() async {
    try {
      final response = await http.get(
        Uri.parse(widget.apiUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _price = double.tryParse(
            jsonData['data']['attributes']['base_token_price_usd'] ?? '0',
          ) ?? 0.0;
          _percentageChange = double.tryParse(
            jsonData['data']['attributes']['base_token_price_change_percentage'] ?? '0',
          ) ?? 0.0;
          _isLoading = false;
          _error = '';
        });
      } else {
        setState(() {
          _error = 'Error loading data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showDonationInfo = !_showDonationInfo;
          });
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF004e92)], // Тёмно-синий градиент
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: 300,
            height: 250,
            child: Center(
              child: _showDonationInfo ? _buildDonationInfo() : _buildPriceInfo(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo() {
    double progress = _price / 777; // 777 - твоя целевая цена

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : _error.isNotEmpty
                ? Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  )
                : Column(
                    children: [
                      Text(
                        widget.memcoinName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron', // Футуристичный шрифт
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_price != 0)
                        Text(
                          '\$${_price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (_percentageChange != 0)
                        Text(
                          '${_percentageChange > 0 ? '↑' : '↓'} ${_percentageChange.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: _percentageChange > 0 ? Colors.green : Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.memcoinAmount} ${widget.currency}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 20,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Progress: ${(progress * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget _buildDonationInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Support the author',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 10),
        const SelectableText(
          walletAddress,  // Используем переменную из файла constants.dart
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: walletAddress));  // Используем переменную из файла constants.dart
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address copied')),
            );
          },
          child: const Text('Copy Address'),
        ),
      ],
    );
  }
}
