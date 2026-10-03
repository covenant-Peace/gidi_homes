/// Core domain enums for GidiHomes.
library;

enum ListingType {
  rent, // yearly rent — the dominant Lagos model
  shortlet, // serviced / short-stay apartments (per night)
  land; // plots of land for sale

  String get label => switch (this) {
        ListingType.rent => 'For Rent',
        ListingType.shortlet => 'Shortlet',
        ListingType.land => 'Land',
      };

  /// How the price should be read for this listing type.
  String get priceSuffix => switch (this) {
        ListingType.rent => '/year',
        ListingType.shortlet => '/night',
        ListingType.land => '',
      };
}

/// Nigerian land-title documents buyers look for.
enum LandTitle {
  certificateOfOccupancy('C of O'),
  governorsConsent("Governor's Consent"),
  deedOfAssignment('Deed of Assignment'),
  surveyPlan('Survey Plan'),
  excision('Excision'),
  gazette('Gazette'),
  freehold('Freehold');

  const LandTitle(this.label);
  final String label;
}

enum UserRole {
  buyer,
  agent;

  String get label => this == UserRole.agent ? 'Agent / Landlord' : 'Buyer / Renter';
}

/// Furnishing state (relevant for rent & shortlet).
enum Furnishing {
  unfurnished('Unfurnished'),
  semiFurnished('Semi-furnished'),
  furnished('Fully furnished'),
  serviced('Serviced');

  const Furnishing(this.label);
  final String label;
}

enum SortOption {
  newest('Newest'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low');

  const SortOption(this.label);
  final String label;
}
