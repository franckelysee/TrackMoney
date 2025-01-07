import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/social_media_buttons.dart';
import 'package:trackmoney/templates/pages/screens/devise.dart';
import 'package:trackmoney/utils/app_config.dart';
import 'package:trackmoney/utils/devise_list.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Simuler une logique d'inscription ou de connexion
  // void _handleAuthentication() async {
  //   // Logique d'inscription ou de connexion ici
  //   // Par exemple, après l'inscription ou la connexion réussie :
    
  //   // Une fois l'utilisateur authentifié, mettre à jour l'indicateur "isFirstLaunch"
  //   await Database.setFirstLaunch(false); // Marquer que ce n'est plus le premier lancement

  //   // Naviguer vers la HomePage
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomePage()),
  //   );
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFirstLaunch();
  }


  setFirstLaunch() async{
    await Database.setFirstLaunch(false);
  }

  @override

  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const  EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Expanded(child: 
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'TrackMoney',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                    Text(
                      "'Parce que chaque dépense a son importance.'",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: AppConfig.primaryColor,
                        fontStyle: FontStyle.italic
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                )
              ),
            ),
            const SizedBox(height: 20,),
            const SizedBox(height: 20),
            const SizedBox(height: 20,),
            const MyButton(label: "S'inscrire", onPressed: null, color: AppConfig.primaryColor),
            const SizedBox(height: 20,),
            const MyButton(label: "Se connecter", onPressed: null, color: Color(0xFFD9D9D9), textColor: Colors.black),
            const SizedBox(height: 50,),
            const SocialMediaButtons(onFacebookPressed: null, onGooglePressed: null),
            const SizedBox(height: 20,),
            const SizedBox(height: 20,),
            Expanded(child: 
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: (){
                    Navigator.of(context).push(CreateROute(DeviseSelector(devises: devises,)));
                  },
                  child: const Text(
                    "Continuer sans créer de compte",
                    style: TextStyle(color: AppConfig.primaryColor),
                  )
                ),
              )
            ),
            
          ],
        ),
      ),
    );
  }
}