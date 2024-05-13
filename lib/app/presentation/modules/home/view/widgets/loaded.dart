import 'package:blockchain/app/domain/models/crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

const colors = <String, Color>{
  'BTC': Colors.orange,
  'ETH': Colors.deepPurple,
  'USDT': Colors.green,
  'BNB': Colors.yellow,
  'USDC': Colors.blue,
  'DOGE': Colors.deepOrange,
  'LTC': Colors.grey,
  'XMR': Colors.deepOrangeAccent,
};

class HomeLoaded extends StatelessWidget {
  const HomeLoaded({required this.cryptos, super.key});

  final List<Crypto> cryptos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, index) {
        final crypto = cryptos[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: Colors.white,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/${crypto.symbol}.svg',
                  width: 30,
                  height: 30,
                  color: colors[crypto.symbol],
                ),
              ],
            ),
            title: Text(
                crypto.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(crypto.symbol),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat.currency(name: r'$').format(
                    crypto.price,
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${crypto.changePercent24Hr.toStringAsFixed(2)}%',
                  style: TextStyle(
                      color: crypto.changePercent24Hr.isNegative
                          ? Colors.redAccent
                          : Colors.green),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: cryptos.length,
    );
  }
}
