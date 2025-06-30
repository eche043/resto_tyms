// lib/common/widgets/restaurant_card.dart
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:odrive_restaurant/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';

class RestaurantCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String updateDate;
  final String imageUrl;
  final bool isPublished;
  final bool isPaused; // Nouveau paramètre
  final Map<String, String> openingHours; // Nouveau paramètre
  final Function onPublish;
  final Function(bool) onPauseToggle; // Remplace onEdit
  final Function(Map<String, String>) onHoursChanged; // Remplace onDelete
  final bool isLoading;

  RestaurantCard({
    required this.title,
    required this.orderId,
    required this.updateDate,
    required this.imageUrl,
    required this.isPublished,
    this.isPaused = false,
    this.openingHours = const {}, // Valeur par défaut
    required this.onPublish,
    required this.onPauseToggle,
    required this.onHoursChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    RestaurantsProvider restaurantsProvider =
        Provider.of<RestaurantsProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: greyScale900Color,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              orderId,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              updateDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Badge de publication
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  isPublished ? appColor : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPublished ? "Published" : "Draft",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Badge de statut (pause/ouvert/fermé)
                          _buildRestaurantStatusBadge(),
                        ],
                      ),
                    ],
                  ),
                ),

                // Affichage des heures actuelles
                if (openingHours.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _buildCurrentHoursDisplay(),
                  ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          // Actions buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Heures d'ouverture
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showOpeningHoursDialog(context),
                    icon: Icon(Icons.schedule, size: 18),
                    label: Text("Horaires"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Bouton Pause/Reprendre
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showPauseConfirmationDialog(context),
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      size: 18,
                    ),
                    label: Text(isPaused ? "Reprendre" : "Pause"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPaused ? Colors.green[600] : Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Badge de statut du restaurant
  Widget _buildRestaurantStatusBadge() {
    Color color;
    String text;
    IconData icon;

    if (isPaused) {
      color = Colors.orange;
      text = 'En pause';
      icon = Icons.pause_circle;
    } else if (_isCurrentlyOpen()) {
      color = Colors.green;
      text = 'Ouvert';
      icon = Icons.check_circle;
    } else {
      color = Colors.red;
      text = 'Fermé';
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Affichage des heures actuelles
  Widget _buildCurrentHoursDisplay() {
    final today = _getCurrentDayKey();
    final todayHours = openingHours[today] ?? 'Non défini';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            'Aujourd\'hui: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            todayHours,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog de confirmation pour la pause
  void _showPauseConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: isPaused ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPaused ? 'Reprendre l\'activité' : 'Mettre en pause',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[700], height: 1.4),
                children: [
                  TextSpan(
                    text: isPaused
                        ? 'Voulez-vous reprendre l\'activité de '
                        : 'Voulez-vous mettre en pause ',
                  ),
                  TextSpan(
                    text: '"$title"',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: appColor),
                  ),
                  const TextSpan(text: ' ?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    (isPaused ? Colors.green : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (isPaused ? Colors.green : Colors.orange)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: isPaused ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isPaused
                          ? 'Le restaurant recommencera à accepter les commandes.'
                          : 'Le restaurant n\'acceptera plus de nouvelles commandes.',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isPaused ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onPauseToggle(!isPaused);
              _showSuccessSnackBar(context);
            },
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 16),
            label: Text(isPaused ? 'Reprendre' : 'Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaused ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog pour modifier les heures d'ouverture
  void _showOpeningHoursDialog(BuildContext context) {
    final Map<String, String> editedHours =
        Map.from(openingHours.isEmpty ? _getDefaultHours() : openingHours);
    print("openingHours______________-");
    print(openingHours);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule, color: appColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Heures d\'ouverture',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Définissez les heures d\'ouverture pour chaque jour',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          'lundi',
                          'mardi',
                          'mercredi',
                          'jeudi',
                          'vendredi',
                          'samedi',
                          'dimanche'
                        ].map((day) => _buildDayHoursEditor(
                            day, editedHours, setState, context)),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          print("editedHours new_________-");
                          print(editedHours);
                          onHoursChanged(editedHours);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Heures d\'ouverture mises à jour'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Éditeur pour les heures d'un jour
  Widget _buildDayHoursEditor(String day, Map<String, String> hours,
      Function setState, BuildContext context) {
    final currentHours = hours[day] ?? '08:00-22:00';
    final isClosed = currentHours == 'Fermé';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Première ligne : Nom du jour et checkbox
          Row(
            children: [
              // Nom du jour
              Expanded(
                flex: 3,
                child: Text(
                  day,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),

              // Checkbox ouvert/fermé
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Checkbox(
                      value: !isClosed,
                      onChanged: (value) {
                        setState(() {
                          hours[day] = value! ? '08:00-22:00' : 'Fermé';
                        });
                      },
                      activeColor: appColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Flexible(
                      child: Text('Ouvert', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Deuxième ligne : Sélection des heures (si ouvert)
          if (!isClosed)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Text(
                    'Horaires: ',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTimeRange(context, day, currentHours,
                          (newHours) {
                        setState(() {
                          hours[day] = newHours;
                        });
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          currentHours,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Sélection libre des heures avec time picker
  void _selectTimeRange(BuildContext context, String day, String currentRange,
      Function(String) onChanged) {
    // Extraire les heures actuelles
    String currentOpenTime = '08:00';
    String currentCloseTime = '22:00';

    if (currentRange != 'Fermé' && currentRange.contains('-')) {
      final parts = currentRange.split('-');
      if (parts.length == 2) {
        currentOpenTime = parts[0].trim();
        currentCloseTime = parts[1].trim();
      }
    }

    // Variables pour stocker les nouvelles heures
    String selectedOpenTime = currentOpenTime;
    String selectedCloseTime = currentCloseTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.access_time, color: appColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Horaires pour ${day}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sélection heure d'ouverture
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny,
                                color: Colors.green[700], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Heure d\'ouverture',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await _showTimePicker(
                                context, selectedOpenTime);
                            if (time != null) {
                              setDialogState(() {
                                selectedOpenTime = time;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedOpenTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.schedule, color: Colors.green[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sélection heure de fermeture
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_twilight,
                                color: Colors.orange[700], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Heure de fermeture',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await _showTimePicker(
                                context, selectedCloseTime);
                            if (time != null) {
                              setDialogState(() {
                                selectedCloseTime = time;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedCloseTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.schedule, color: Colors.orange[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Aperçu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: appColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: appColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: appColor, fontSize: 12),
                              children: [
                                const TextSpan(text: 'Aperçu: '),
                                TextSpan(
                                  text:
                                      '$selectedOpenTime - $selectedCloseTime',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Validation simple
                          if (_isValidTimeRange(
                              selectedOpenTime, selectedCloseTime)) {
                            Navigator.pop(context);
                            onChanged('$selectedOpenTime-$selectedCloseTime');
                          } else {
                            _showTimeValidationError(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirmer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Afficher le time picker
  Future<String?> _showTimePicker(
      BuildContext context, String currentTime) async {
    // Convertir la chaîne en TimeOfDay
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: appColor,
                    onSurface: Colors.black,
                  ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // Convertir en format HH:MM
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }

    return null;
  }

  // Valider que l'heure d'ouverture est avant l'heure de fermeture
  bool _isValidTimeRange(String openTime, String closeTime) {
    try {
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');

      final openMinutes =
          int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeMinutes =
          int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

      // Permettre les horaires qui traversent minuit (ex: 22:00-02:00)
      // Si l'heure de fermeture est plus petite, on considère que c'est le lendemain
      return openMinutes !=
          closeMinutes; // Juste s'assurer qu'elles ne sont pas identiques
    } catch (e) {
      return false;
    }
  }

  // Afficher un message d'erreur pour la validation
  void _showTimeValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Heures invalides'),
          ],
        ),
        content: const Text(
          'L\'heure d\'ouverture et de fermeture ne peuvent pas être identiques.\n\n'
          'Si votre restaurant est ouvert 24h/24, utilisez par exemple 00:00-23:59.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  // Utilitaires
  String _getCurrentDayKey() {
    final days = [
      'dimanche',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi'
    ];
    return days[DateTime.now().weekday % 7];
  }

  bool _isCurrentlyOpen() {
    if (openingHours.isEmpty)
      return true; // Par défaut ouvert si pas d'horaires définies

    final today = _getCurrentDayKey();
    final todayHours = openingHours[today];

    if (todayHours == null || todayHours == 'Fermé') return false;

    // Logique simplifiée - vous pouvez améliorer avec l'heure actuelle
    return true;
  }

  Map<String, String> _getDefaultHours() {
    return {
      'lundi': '08:00-22:00',
      'mardi': '08:00-22:00',
      'mercredi': '08:00-22:00',
      'jeudi': '08:00-22:00',
      'vendredi': '08:00-22:00',
      'samedi': '08:00-22:00',
      'dimanche': 'Fermé',
    };
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isPaused
                    ? '$title reprend son activité'
                    : '$title mis en pause',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isPaused ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Extension pour capitaliser les strings
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
