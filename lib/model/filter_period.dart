enum FilterPeriod {
  lastUpdated,
  last7Days,
  last30Days,
  custom,
}

extension FilterPeriodExtension on FilterPeriod {
  String get displayName {
    switch (this) {
      case FilterPeriod.lastUpdated:
        return 'Last updated';
      case FilterPeriod.last7Days:
        return 'Last 7 days';
      case FilterPeriod.last30Days:
        return 'Last 30 days';
      case FilterPeriod.custom:
        return 'Custom';
    }
  }

  String get displayNameFr {
    switch (this) {
      case FilterPeriod.lastUpdated:
        return 'Dernière mise à jour';
      case FilterPeriod.last7Days:
        return '7 derniers jours';
      case FilterPeriod.last30Days:
        return '30 derniers jours';
      case FilterPeriod.custom:
        return 'Personnalisé';
    }
  }
}
