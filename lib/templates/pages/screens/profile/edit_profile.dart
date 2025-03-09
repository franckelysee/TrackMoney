import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/utils/app_config.dart';


class EditeProfile extends StatefulWidget {
  const EditeProfile({ Key? key }) : super(key: key);

  @override
  _EditeProfileState createState() => _EditeProfileState();
}

class _EditeProfileState extends State<EditeProfile> {
  Color btnTecxtColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        title: Text("Modifer le Profile", style: TextStyle(fontSize: 20),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 100),
                      child: Image(
                        image: AssetImage('assets/images/profile/salon.png'),
                        fit: BoxFit.cover,
                      )
                    ),
                    // bouton pour ajouter la photo de couverture
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: IconButton(
                        onPressed: (){}, 
                        icon: Icon(Icons.camera_alt, color: Colors.white,)
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      InkWell(
                        onTap: () {
                          
                        },
                        child: Container(
                          width: 195,
                          height: 195,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(100)
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/images/profile/avatar.jpeg'),
                          ),
                        ),
                      ),
                      // update user profile image
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: IconButton(
                          onPressed: (){}, 
                          icon: Icon(Icons.camera_alt, color: Colors.white,)
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 40,),
            Container(
              padding: EdgeInsets.all(10),
              child: Form(
                child: Column(
                  children: [
                    // Nome et Description
                    CustomTextFormField(
                      hintText: "Nom d'utilisateur",
                      labelText: "Nom d'utilisateur",
                    ),
                    SizedBox(height: 10,),
                    CustomTextFormField(
                      hintText: "E-mail",
                      labelText: "E-mail",
                    ),
                    SizedBox(height: 10,),
                    CustomTextFormField(
                      hintText: "Mot de passe",
                      labelText: "Mot de passe",
                      isPassword: true,
                      suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.remove_red_eye_sharp)),
                    ),
                    SizedBox(height: 10,),
                    CustomTextFormField(
                      hintText: "12/04/2000",
                      labelText: "Date de naissance",
                      suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.calendar_month)),
                    ),
                    SizedBox(height: 10,),
                    CustomTextFormField(
                      hintText: "Pays",
                      labelText: "Pays",
                    ),
                    SizedBox(height: 10,),
                    CustomTextFormField(
                      hintText: "ville",
                      labelText: "ville",
                    ),
                    SizedBox(height: 10,),
                    Column(
                      children: [
                        Text("Dévise par défaut", style: TextStyle(fontSize: 18),),
                        SizedBox(height: 10,),
                        CustomDropdownButtonFormField(
                          initialValue: 'XAF',
                          items: ['XAF'], 
                          onChanged: (value){}
                        ),
                      ],
                    ),
                    SizedBox(height: 50,),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextButton(
                        onHover: (value) {
                          if(value){
                            btnTecxtColor = Colors.grey;
                          }else{
                            btnTecxtColor = Colors.white;
                          }
                          setState(() {});
                        },
                        onPressed: (){
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        },
                        child: Text("Mettre A jour", style: TextStyle(color: btnTecxtColor),)
                      ),
                    )
                        
                  ],
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}