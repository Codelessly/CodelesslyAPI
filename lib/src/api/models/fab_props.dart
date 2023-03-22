// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

/// Type of the FAB based on its size.
enum FloatingActionButtonType {
  /// A FAB with regular size.
  regular(56),

  /// A FAB with size smaller than regular.
  small(40),

  /// A FAB with size larger than regular.
  large(96),

  /// A FAB with icon and text.
  extended(48);

  /// Size value for this FAB.
  final double size;

  /// Whether this FAB is extended.
  bool get isExtended => this == FloatingActionButtonType.extended;

  /// Default constructor for this enum.
  const FloatingActionButtonType(this.size);
}

/// Specifies the relative location of a FAB.
enum FABLocation {
  /// Start-aligned [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body.
  /// See Flutter docs for more info.
  startTop('Start Top'),

  /// Start-aligned [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body, optimized for mini floating
  /// action buttons.
  /// See Flutter docs for more info.
  miniStartTop('Mini Start Top'),

  /// Centered [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body.
  /// See Flutter docs for more info.
  centerTop('Center Top'),

  /// Centered [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body, intended to be used with
  /// [FloatingActionButton.mini] set to true.
  /// See Flutter docs for more info.
  miniCenterTop('Mini Center Top'),

  /// End-aligned [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body.
  /// See Flutter docs for more info.
  endTop('End Top'),

  /// End-aligned [FloatingActionButton], floating over the transition between
  /// the Scaffold appBar and the Scaffold body, optimized for mini floating
  /// action buttons.
  /// See Flutter docs for more info.
  miniEndTop('Mini End Top'),

  /// Start-aligned [FloatingActionButton], floating at the bottom of the screen.
  /// See Flutter docs for more info.
  startFloat('Start Float'),

  /// Start-aligned [FloatingActionButton], floating at the bottom of the screen,
  /// optimized for mini floating action buttons.
  /// See Flutter docs for more info.
  miniStartFloat('Mini Start Float'),

  /// Centered [FloatingActionButton], floating at the bottom of the screen.
  /// See Flutter docs for more info.
  centerFloat('Center Float'),

  /// Centered [FloatingActionButton], floating at the bottom of the screen,
  /// optimized for mini floating action buttons.
  /// See Flutter docs for more info.
  miniCenterFloat('Mini Center Float'),

  /// End-aligned [FloatingActionButton], floating at the bottom of the screen.
  /// See Flutter docs for more info.
  endFloat('End Float'),

  /// End-aligned [FloatingActionButton], floating at the bottom of the screen,
  /// optimized for mini floating action buttons.
  /// See Flutter docs for more info.
  miniEndFloat('Mini End Float'),

  /// Start-aligned [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar.
  /// See Flutter docs for more info.
  startDocked('Start Docked'),

  /// Start-aligned [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar,
  /// optimized for mini floating action buttons.
  /// See Flutter docs for more info.
  miniStartDocked('Mini Start Docked'),

  /// Centered [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar.
  /// See Flutter docs for more info.
  centerDocked('Center Docked'),

  /// Centered [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar;
  /// intended to be used with [FloatingActionButton.mini] set to true.
  /// See Flutter docs for more info.
  miniCenterDocked('Mini Center Docked'),

  /// End-aligned [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar.
  /// See Flutter docs for more info.
  endDocked('End Docked'),

  /// End-aligned [FloatingActionButton], floating over the
  /// [Scaffold.bottomNavigationBar] so that the center of the floating
  /// action button lines up with the top of the bottom navigation bar,
  /// optimized for mini floating action buttons.
  /// See Flutter docs for more info.
  miniEndDocked('Mini End Docked');

  /// Displayable string representation of this enum.
  final String label;

  /// Default constructor for this enum.
  const FABLocation(this.label);

  /// Whether this location is for mini FAB.
  bool get isMini =>
      this == FABLocation.miniStartTop ||
      this == FABLocation.miniCenterTop ||
      this == FABLocation.miniEndTop ||
      this == FABLocation.miniStartFloat ||
      this == FABLocation.miniCenterFloat ||
      this == FABLocation.miniEndFloat ||
      this == FABLocation.miniStartDocked ||
      this == FABLocation.miniCenterDocked ||
      this == FABLocation.miniEndDocked;
}

/// Location values for a regular sized FAB.
const FABLocationsNormal = [
  FABLocation.startTop,
  FABLocation.miniStartTop,
  FABLocation.centerTop,
  FABLocation.miniCenterTop,
  FABLocation.endTop,
  FABLocation.miniEndTop,
];

/// Location values for a floating FAB.
const FABLocationsFloat = [
  FABLocation.startFloat,
  FABLocation.miniStartFloat,
  FABLocation.centerFloat,
  FABLocation.miniCenterFloat,
  FABLocation.endFloat,
  FABLocation.miniEndFloat,
];

/// Location values for a docked FAB.
const FABLocationsDocked = [
  FABLocation.startDocked,
  FABLocation.miniStartDocked,
  FABLocation.centerDocked,
  FABLocation.miniCenterDocked,
  FABLocation.endDocked,
  FABLocation.miniEndDocked,
];
