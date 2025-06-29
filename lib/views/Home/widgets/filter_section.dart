import 'package:flutter/material.dart';
import 'package:odrive_restaurant/model/filter_period.dart';

class FilterSection extends StatefulWidget {
  final FilterPeriod selectedPeriod;
  final Function(FilterPeriod) onPeriodChanged;
  final Function(DateTime, DateTime) onCustomPeriodSelected;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const FilterSection({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onCustomPeriodSelected,
    this.customStartDate,
    this.customEndDate,
  }) : super(key: key);

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Initialiser avec les dates fournies ou des valeurs par défaut
    _startDate = widget.customStartDate ??
        DateTime.now().subtract(const Duration(days: 30));
    _endDate = widget.customEndDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(FilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour les dates si elles changent depuis le parent
    if (widget.customStartDate != oldWidget.customStartDate ||
        widget.customEndDate != oldWidget.customEndDate) {
      _startDate = widget.customStartDate ?? _startDate;
      _endDate = widget.customEndDate ?? _endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Boutons de filtre
          _buildFilterButtons(),

          const SizedBox(height: 12),

          // Sélecteur de période personnalisée
          _buildCustomPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur petit écran, afficher en colonne
        //if (constraints.maxWidth < 400) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    FilterPeriod.lastUpdated,
                    'Dernière maj',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    FilterPeriod.last7Days,
                    '7 derniers jours',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _buildFilterButton(
                FilterPeriod.last30Days,
                '30 derniers jours',
              ),
            ),
          ],
        );
        //}

        // Sur grand écran, afficher en ligne
        /* return Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                FilterPeriod.lastUpdated,
                'Dernière maj',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterButton(
                FilterPeriod.last7Days,
                '7 derniers jours',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterButton(
                FilterPeriod.last30Days,
                '30 derniers jours',
              ),
            ),
          ],
        ); */
      },
    );
  }

  Widget _buildCustomPeriodSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur petit écran, afficher en colonne
        //if (constraints.maxWidth < 500) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    _formatDate(_startDate),
                    isStartDate: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: _buildDatePicker(
                    _formatDate(_endDate),
                    isStartDate: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _buildConfirmButton(),
            ),
          ],
        );
        //}

        // Sur grand écran, afficher en ligne
        /* return Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                _formatDate(_startDate),
                isStartDate: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('—', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: _buildDatePicker(
                _formatDate(_endDate),
                isStartDate: false,
              ),
            ),
            const SizedBox(width: 12),
            _buildConfirmButton(),
          ],
        ); */
      },
    );
  }

  Widget _buildFilterButton(FilterPeriod period, String text) {
    final isSelected = widget.selectedPeriod == period;

    return InkWell(
      onTap: () => widget.onPeriodChanged(period),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A7C59) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A7C59) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String text, {required bool isStartDate}) {
    return InkWell(
      onTap: () => _showDatePicker(isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _confirmCustomPeriod,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A7C59),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Confirmer',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Future<void> _showDatePicker(bool isStartDate) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = DateTime(2020);
    final DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'), // Optionnel: pour affichage en français
      helpText: isStartDate
          ? 'Sélectionner la date de début'
          : 'Sélectionner la date de fin',
      cancelText: 'Annuler',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Si la date de début est après la date de fin, ajuster la date de fin
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          // Si la date de fin est avant la date de début, ajuster la date de début
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _confirmCustomPeriod() {
    // Validation des dates
    if (_startDate.isAfter(_endDate)) {
      _showErrorDialog(
          'La date de début doit être antérieure à la date de fin.');
      return;
    }

    // Vérifier que la période n'est pas trop longue (par exemple, max 1 an)
    final difference = _endDate.difference(_startDate).inDays;
    if (difference > 365) {
      _showErrorDialog('La période ne peut pas dépasser 365 jours.');
      return;
    }

    // Vérifier que la période n'est pas trop courte
    if (difference < 1) {
      _showErrorDialog('La période doit être d\'au moins 1 jour.');
      return;
    }

    widget.onCustomPeriodSelected(_startDate, _endDate);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de période'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
