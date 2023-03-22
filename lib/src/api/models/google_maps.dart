// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// The different modes the Google Maps API supports.
enum GoogleMapsMapMode {
  /// Google places view.
  places('Places'),

  /// Google maps in viewing mode.
  view('View'),

  /// Google maps in directions mode.
  directions('Directions'),

  /// Google maps in street view mode.
  streetView('Street View'),

  /// Google maps in search mode.
  search('Search');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructors for this enum.
  const GoogleMapsMapMode(this.label);
}

/// The different types of tile rendering the Google Maps API supports.
enum GoogleMapsMapType {
  /// Google maps in road map view with highlighted roads.
  roadmap('Roadmap'),

  /// Satellite view.
  satellite('Satellite');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructors for this enum.
  const GoogleMapsMapType(this.label);
}

/// Different modes for the directions map view.
enum GoogleMapsDirectionsMode {
  /// Shows directions for cars and other vehicles.
  driving('Driving'),

  /// Shows directions for walking.
  walking('Walking'),

  /// Shows directions for cycling.
  bicycling('Bicycling'),

  /// Shows route for public transits available.
  transit('Transit'),

  /// Shows route for flying.
  flying('Flying');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructor for this enum.
  const GoogleMapsDirectionsMode(this.label);
}

/// Different types of routes to avoid.
enum GoogleMapsDirectionsAvoid {
  /// Avoid roads with tolls.
  tolls('Tolls'),

  /// Avoid highways.
  highways('Highways'),

  /// Avoid water routes with ferries.
  ferries('Ferries');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructor for this enum.
  const GoogleMapsDirectionsAvoid(this.label);
}

/// The different unit measurement systems the Google Maps API supports.
enum UnitSystem {
  /// Represents Metric unit system.
  metric('Metric'),

  /// Represents Imperial unit system.
  imperial('Imperial');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructor for this enum.
  const UnitSystem(this.label);
}
