import 'package:flutter/material.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/schemas/transaction_schema.dart';
import 'package:trackmoney/services/account_service.dart';
import 'package:trackmoney/services/category_service.dart';
import 'package:trackmoney/services/transaction_service.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';

class AccountDetailsPage extends StatefulWidget {
  final AccountModel account;

  const AccountDetailsPage({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  bool _isLoading = true;
  List<TransactionSchema> _accountTransactions = [];
  Map<String, dynamic> _transactionStats = {
    'in': {'count': 0, 'amount': 0.0},
    'out': {'count': 0, 'amount': 0.0},
  };

  bool _hasTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadAccountTransactions();
  }

  // Méthode pour afficher la boîte de dialogue d'édition du compte
  void _showEditAccountDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: widget.account.name);
    final TextEditingController amountController = TextEditingController(text: widget.account.balance.toString());

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Modifier le portefeuille",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ pour le nom du compte
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nom du portefeuille",
                    hintText: "Ex: Mon compte bancaire",
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Champ pour le montant (désactivé si des transactions existent)
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  enabled: !_hasTransactions,
                  decoration: InputDecoration(
                    labelText: "Montant disponible",
                    hintText: "0.00",
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: _hasTransactions
                        ? "Le montant ne peut pas être modifié car des transactions existent"
                        : null,
                    helperMaxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Annuler",
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _updateAccount(
                  nameController.text,
                  double.tryParse(amountController.text) ?? widget.account.balance!
                );
                Navigator.pop(context);
              },
              child: Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour mettre à jour le compte
  Future<void> _updateAccount(String name, double amount) async {
    try {
      // Créer une copie mise à jour du compte
      final updatedAccount = AccountModel(
        id: widget.account.id,
        name: name,
        type: widget.account.type,
        balance: _hasTransactions ? widget.account.balance : amount,
      );

      // Mettre à jour le compte dans la base de données
      await AccountService.updateAccount(updatedAccount);

      // Rafraîchir les données
      if (mounted) {
        setState(() {
          // Mettre à jour l'objet account dans le widget
          widget.account.name = name;
          if (!_hasTransactions) {
            widget.account.balance = amount;
          }
        });

        // Afficher un message de succès
        SnackbarNotifier.show(
          context: context,
          message: "Portefeuille mis à jour avec succès",
          type: 'success',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarNotifier.show(
          context: context,
          message: "Erreur lors de la mise à jour du portefeuille: $e",
          type: 'error',
        );
      }
    }
  }

  // Méthode pour afficher la boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "Supprimer le portefeuille",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Êtes-vous sûr de vouloir supprimer ce portefeuille ?",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                _hasTransactions
                    ? "Attention : Toutes les transactions associées à ce portefeuille seront également supprimées."
                    : "Cette action est irréversible.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Annuler",
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
                _deleteAccount(); // Supprimer le compte
              },
              child: Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour supprimer le compte
  Future<void> _deleteAccount() async {
    try {
      final accountId = widget.account.id;
      if (accountId != null) {
        // Supprimer le compte en utilisant le service
        await AccountService.deleteAccount(accountId);

        // Supprimer également toutes les transactions associées à ce compte
        if (_hasTransactions) {
          // Récupérer toutes les transactions pour ce compte
          final transactions = await TransactionService.getTransactionsByAccount(accountId);

          // Supprimer chaque transaction
          for (var transaction in transactions) {
            await TransactionService.deleteTransaction(transaction.id);
          }
        }

        // Retourner à la page précédente avec un résultat pour rafraîchir la liste des comptes
        if (mounted) {
          Navigator.pop(context, true);

          // Afficher un message de succès
          SnackbarNotifier.show(
            context: context,
            message: "Portefeuille supprimé avec succès",
            type: 'success',
          );
        }
      } else {
        throw Exception("ID de compte manquant");
      }
    } catch (e) {
      if (mounted) {
        SnackbarNotifier.show(
          context: context,
          message: "Erreur lors de la suppression du portefeuille: $e",
          type: 'error',
        );
      }
    }
  }

  Future<void> _loadAccountTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer toutes les transactions pour ce compte
      final transactions = await TransactionService.getAllTransactions();
      final categories = await CategoryService.getAllCategories();

      // Filtrer les transactions pour ce compte spécifique
      final accountTransactions = transactions
          .where((transaction) => transaction.accountId == widget.account.id)
          .toList();

      // Transformer les transactions en TransactionSchema
      final transactionSchemas = accountTransactions.map((transaction) {
        // Trouver la catégorie correspondante
        dynamic category;
        for (var cat in categories) {
          if (cat.id == transaction.categoryId) {
            category = cat;
            break;
          }
        }

        return TransactionSchema(
          id: transaction.id,
          name: transaction.name,
          type: transaction.type,
          amount: transaction.amount,
          icon: category?.icon,
          iconcolor: category?.colorValue,
          category: category?.name ?? 'Catégorie inconnue',
          date: transaction.date,
          account_id: transaction.accountId,
        );
      }).toList();

      // Trier par date (plus récentes en premier)
      transactionSchemas.sort((a, b) => b.date!.compareTo(a.date!));

      // Calculer les statistiques
      double totalIn = 0;
      double totalOut = 0;
      int countIn = 0;
      int countOut = 0;

      for (var transaction in accountTransactions) {
        if (transaction.type == TransactionTypesEnum.revenu) {
          totalIn += transaction.amount;
          countIn++;
        } else if (transaction.type == TransactionTypesEnum.depense) {
          totalOut += transaction.amount;
          countOut++;
        }
      }

      if (mounted) {
        setState(() {
          _accountTransactions = transactionSchemas;
          _transactionStats = {
            'in': {'count': countIn, 'amount': totalIn},
            'out': {'count': countOut, 'amount': totalOut},
          };
          // Définir si le compte a des transactions (pour la modification du montant)
          _hasTransactions = accountTransactions.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        SnackbarNotifier.show(
          context: context,
          message: "Erreur lors du chargement des transactions: $e",
          type: 'error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surface
            : Color(0xFFF8F9FA),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Détails du portefeuille",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton d'édition
          IconButton(
            icon: Icon(
              Icons.edit,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              _showEditAccountDialog(context);
            },
          ),
          // Bouton de suppression
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte du compte
                  CardComponent(
                    amount: widget.account.balance!,
                    accountType: widget.account.type!,
                    accountName: widget.account.name!,
                    accountId: widget.account.id,
                    hideDetails: true, // Masquer le bouton "Détails"
                  ),

                  SizedBox(height: 24),

                  // Statistiques des transactions
                  _buildTransactionStats(theme, isDarkMode),

                  SizedBox(height: 24),

                  // Liste des transactions
                  _buildTransactionsList(theme, isDarkMode),
                ],
              ),
            ),
    );
  }

  Widget _buildTransactionStats(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : Colors.grey.withAlpha(30),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statistiques du portefeuille",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                  title: "Entrées",
                  count: _transactionStats['in']['count'],
                  amount: _transactionStats['in']['amount'],
                  theme: theme,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                  title: "Sorties",
                  count: _transactionStats['out']['count'],
                  amount: _transactionStats['out']['amount'],
                  theme: theme,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required double amount,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor == Colors.green
                      ? Color(0x1A4CAF50) // Vert avec alpha 10%
                      : Color(0x1AF44336), // Rouge avec alpha 10%
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "$count transaction${count > 1 ? 's' : ''}",
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            "${amount.toStringAsFixed(0)} FCFA",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme, bool isDarkMode) {
    if (_accountTransactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black26
                  : Colors.grey.withAlpha(30),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                "Aucune transaction pour ce portefeuille",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Les transactions effectuées avec ce portefeuille apparaîtront ici",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : Colors.grey.withAlpha(30),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transactions récentes",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _accountTransactions.length > 10 ? 10 : _accountTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _accountTransactions[index];

              // Déterminer les couleurs en fonction du type de transaction
              Color iconBgColor = transaction.type == TransactionTypesEnum.depense
                  ? Color(0xFFF44336) // Rouge pour les dépenses
                  : Color(0xFF4CAF50); // Vert pour les revenus

              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: NotificatedCard(
                  title: transaction.name!,
                  titleSize: 16,
                  subtitle: transaction.category,
                  subtitleSize: 13,
                  icon: transaction.icon,
                  price: transaction.type == TransactionTypesEnum.depense
                      ? -transaction.amount!
                      : transaction.amount!,
                  iconBackgroundColor: iconBgColor,
                  date: transaction.date!,
                  backgroundColor: isDarkMode
                      ? theme.colorScheme.surfaceContainerLow
                      : Colors.grey[50],
                  textColor: isDarkMode ? Colors.white : null,
                ),
              );
            },
          ),
          if (_accountTransactions.length > 10)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Naviguer vers une page avec toutes les transactions
                    SnackbarNotifier.show(
                      context: context,
                      message: "Fonctionnalité à venir",
                      type: 'info',
                    );
                  },
                  child: Text(
                    "Voir toutes les transactions",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
