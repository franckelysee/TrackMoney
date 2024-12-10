import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';



class CustomSpendingBottomModal extends StatefulWidget {
  final TextEditingController categoryController;
  final TextEditingController spendingNameController;

  const CustomSpendingBottomModal({
    super.key,
    required this.categoryController,
    required this.spendingNameController,
  });
  @override
  State<CustomSpendingBottomModal> createState() =>
      _CustomSpendingBottomModalState();
}

class _CustomSpendingBottomModalState extends State<CustomSpendingBottomModal> {
  final modalFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: modalFormKey,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with GestureDetector
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: GestureDetector(
                onTap: () {
                  // Handle card tap
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 50,
                    ),
                    Text(
                      "Ajouter une Icon",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Spending Name TextFormField
            CustomTextFormField(
              controller: widget.spendingNameController,
              labelText: 'Entrer le nom de la dépense eg:Burger',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Category TextFormField
            CustomTextFormField(
              controller: widget.categoryController,
              labelText: 'Entrer le nom de la category eg:Food',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Ajouter',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                onPressed: () {
                  if (modalFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    Navigator.pop(context);
                    // Optionnel: Afficher les données du formulaire dans un SnackBar
                    final spendingName = widget.spendingNameController.text;
                    final category = widget.categoryController.text;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Dépense: $spendingName, Description: $category')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Erreur dans le formulaire')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
