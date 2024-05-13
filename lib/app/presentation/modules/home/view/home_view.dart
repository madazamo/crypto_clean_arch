import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_events.dart';
import '../bloc/home_state.dart';
import 'widgets/error.dart';
import 'widgets/loaded.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(
          HomeState.loading(),
          exchangeRepository: context.read(),
          wsRepository: context.read(),)..add(InitializeEvent()),
      child: Builder(
        builder: (context){
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
      )
    );
  }
}
