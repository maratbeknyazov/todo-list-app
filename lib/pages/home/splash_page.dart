import 'package:flutter/material.dart';
// import 'package:flare_flutter/flare_actor.dart'; // Package deprecated, not installed
import 'package:provider/provider.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/model/global_model.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final model = Provider.of<GlobalModel>(context);

    // Navigate after a delay since FlareActor animation is not available
    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
              return getHomePage(model.goToLogin ?? false);
            }), (router) => false);
      }
    });

    return Scaffold(
      body: Container(
        // TODO(flutter3-migration): flare_flutter and .flr are legacy.
        // Prefer migrating this splash animation to `rive` or `lottie`.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Text(
            'Todo List',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Commented out FlareActor - package not available
        // child: FlareActor(
        //   "flrs/todo_splash.flr",
        //   animation: "run",
        //   fit: BoxFit.cover,
        //   callback: (animation) {
        //     Navigator.of(context).pushAndRemoveUntil(
        //         new MaterialPageRoute(builder: (context) {
        //             return getHomePage(model.goToLogin);
        //         }), (router) => router == null);
        //   },
        // ),
      ),
    );
  }

  Widget getHomePage(bool goToLogin){
    return goToLogin ? ProviderConfig.getInstance().getLoginPage(isFirst: true)
        : ProviderConfig.getInstance().getMainPage();
  }
}
