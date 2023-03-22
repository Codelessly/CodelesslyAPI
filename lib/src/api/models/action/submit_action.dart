// Copyright (c) 2022, Codelessly.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE.md file.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../serializable_mixin.dart';
import 'action.dart';

part 'submit_action.g.dart';

/// Represents supported service for submit action.
enum SubmitActionService {
  /// Mailchimp service for submit action.
  mailchimp;

  /// Displayable string representation of the service.
  String get prettify {
    switch (this) {
      case SubmitActionService.mailchimp:
        return 'Mailchimp';
    }
  }
}

/// An action that submits a form.
@JsonSerializable()
class SubmitAction extends ActionModel with EquatableMixin, SerializableMixin {
  /// Submit service to use.
  SubmitActionService service;

  /// ID of the text field node to submit.
  final String primaryTextField;

  /// API key for for the submit service.
  final String apiKey;

  /// Creates a new [SubmitAction].
  SubmitAction({
    required this.service,
    required this.primaryTextField,
    required this.apiKey,
  }) : super(type: ActionType.submit);

  @override
  List<Object?> get props => [primaryTextField, apiKey];

  /// Creates a new [SubmitAction] instance from a JSON data.
  factory SubmitAction.fromJson(Map json) {
    final SubmitActionService service = _$SubmitActionFromJson(json).service;
    switch (service) {
      case SubmitActionService.mailchimp:
        return MailchimpSubmitAction.fromJson(json);
      default:
        return _$SubmitActionFromJson(json);
    }
  }

  @override
  Map toJson() => _$SubmitActionToJson(this);
}

/// An action that submits a form to Mailchimp.
@JsonSerializable()
class MailchimpSubmitAction extends SubmitAction {
  /// URL of Mailchimp's API endpoint starts with the data center.
  /// For example, if the URL is [https://us6.api.mailchimp.com/3.0/], then the
  /// data center is [us6].
  final String dataCenter;

  /// ID corresponding to subscribers list. It looks like this: [542ad13632].
  final String listID;

  /// Optional field to store the first name of the subscriber.
  /// It referes to the ID of a text field node.
  final String firstNameField;

  /// Optional field to store the last name of the subscriber.
  /// It referes to the ID of a text field node.
  final String lastNameField;

  /// Creates a new [MailchimpSubmitAction].
  MailchimpSubmitAction({
    required super.primaryTextField,
    required super.apiKey,
    required this.dataCenter,
    required this.listID,
    this.firstNameField = '',
    this.lastNameField = '',
  }) : super(service: SubmitActionService.mailchimp);

  @override
  List<Object?> get props => [...super.props, dataCenter, listID];

  /// Duplicate this [MailchimpSubmitAction] with given data overrides.
  MailchimpSubmitAction copyWith({
    String? primaryTextField,
    String? apiKey,
    String? dataCenter,
    String? listID,
    String? firstNameField,
    String? lastNameField,
  }) =>
      MailchimpSubmitAction(
        primaryTextField: primaryTextField ?? this.primaryTextField,
        apiKey: apiKey ?? this.apiKey,
        dataCenter: dataCenter ?? this.dataCenter,
        listID: listID ?? this.listID,
        firstNameField: firstNameField ?? this.firstNameField,
        lastNameField: lastNameField ?? this.lastNameField,
      );

  /// Creates a new [MailchimpSubmitAction] instance from a JSON data.
  factory MailchimpSubmitAction.fromJson(Map json) =>
      _$MailchimpSubmitActionFromJson(json);

  @override
  Map toJson() => _$MailchimpSubmitActionToJson(this);
}
