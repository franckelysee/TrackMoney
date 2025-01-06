import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/spendingModal.dart';
import 'package:trackmoney/templates/header.dart';


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _formsearchkey = GlobalKey<FormState>();
  TextEditingController searchCategoryController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController spendingNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppHeader(title: 'Categories')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Form(
              key: _formsearchkey,
              child:  Row(
                children: [
                Expanded( // Encapsulation dans un `Expanded` pour éviter des problèmes de contraintes.
                  child: CustomTextFormField(
                    controller: searchCategoryController,
                    labelText: 'Rechercher une catégorie',
                    suffixIcon: Icons.search,
                  ),
                ),
                SizedBox( width: 8,),
                CircularButton(
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.add,
                  radius: 10,
                  onpressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                            child: CustomSpendingBottomModal(
                              spendingNameController: spendingNameController,
                              categoryController: categoryController,
                              onCategoryAdded: (newCategory){
                                
                              },
                              
                            )
                          );
                        });
                  }
                )
              ])
            )
           
          ],
        ),
      ),
    );
  }
}