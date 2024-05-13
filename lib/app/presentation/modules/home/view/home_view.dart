import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/home_bloc.dart';
import 'widgets/error.dart';
import 'widgets/loaded.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeBloc(
          exchangeRepository: context.read(),
          wsRepository: context.read())..init(),
      builder: (context, _) {
        final HomeBloc bloc = context.watch();
        return Scaffold(
          backgroundColor: const Color(0xfff2f5f8),
          appBar: AppBar(
            backgroundColor: Colors.blue,
              title: bloc.state.whenOrNull(
                loaded: (_, wsStatus)=>Center(
                  child: Text(
                    wsStatus.when(
                        connecting: ()=>'connecting',
                        connected: ()=>'connected',
                        failed: ()=>'failed',
                    )
                  ),
                ),
              ),
          ),
          body: bloc.state.map(
                loading: (_)=> const Center(
                  child: CircularProgressIndicator(),
                ),
                failed: (state) {
                  HomeError(failure:state.failure);
                },
                loaded: (state)=> HomeLoaded(cryptos: state.cryptos),

            )
        );
      },
    );
  }
}
