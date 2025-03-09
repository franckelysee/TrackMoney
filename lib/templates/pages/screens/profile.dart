import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:trackmoney/utils/app_config.dart';


class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Color btnTecxtColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
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
                Container(
                  alignment: Alignment.center,
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100)
                  ),
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
                )
              ],
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  // Nome et Description
                  Container(
                    child: Column(
                      children: [
                        Text("Mvomo Elysee", style: TextStyle(
                          fontSize: 20,fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary
                        ),),
                        Text("Full-stack Developer", style: TextStyle(
                          fontSize: 14
                        ),)
                      ],
                    ),
                  ), 
                  // adresse et email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width -10) /2 ,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.mapLocation), 
                                SizedBox(width: 10,),
                                Text("Adresse ", 
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                )
                              ],
                            ), 
                            SizedBox(height: 10,),
                            Text("Mimboman Yaoundé, Cameroun", 
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                      ), 
                      Container(
                        width: (MediaQuery.of(context).size.width -10) /2,
                        padding: EdgeInsets.all(8),
                        child: Column(                        
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email), 
                                SizedBox(width: 20,),
                                Text("E-mail")
                              ],
                            ), 
                            SizedBox(height: 10,),
                            Text("franckelysee671@gmail.com",
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  // solde total sur tous les comptes disponible
                  SizedBox(height: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Column(
                      children: [
                        Text("Solde Total".toUpperCase(), style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),),
                        Text("100000 FCFA", style: TextStyle(
                          color: Colors.white, 
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                  ), 
                  SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ), 
                      itemCount: 3,
                      itemBuilder: (context, index){
                        return Container(
                          alignment: Alignment.center,
                          width: 200,
                          height: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(111, 158, 158, 158), 
                    
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("100.000 Fcfa", style: TextStyle(
                                color: Theme.of(context).colorScheme.primary, 
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),),
                              Text("Compte Bancaire")
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                  SizedBox(height: 10,),
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
                      child: Text("Modifier le Profile", style: TextStyle(color: btnTecxtColor),)
                    ),
                  )
        
                ],
              ),
            )
          ],
        ),
      ),

    );
  }
}