import 'package:k2_connect_flutter/src/shared/links.dart';

class StkPushRequestStatus {
  final String id;
  final String type;
  final StkPushRequestAttributes attributes;

  StkPushRequestStatus({
    required this.id,
    required this.type,
    required this.attributes,
  });

  factory StkPushRequestStatus.fromJson(Map<String, dynamic> json) {
    return StkPushRequestStatus(
      id: json['id'],
      type: json['type'],
      attributes: StkPushRequestAttributes.fromJson(json['attributes']),
    );
  }
}

class StkPushRequestAttributes {
  final String initiationTime;
  final String status;
  final Event? event;
  final Map<String, dynamic>? metadata;
  final Links links;

  StkPushRequestAttributes({
    required this.initiationTime,
    required this.status,
    required this.event,
    required this.metadata,
    required this.links,
  });

  factory StkPushRequestAttributes.fromJson(Map<String, dynamic> json) {
    return StkPushRequestAttributes(
      initiationTime: json['initiation_time'],
      status: json['status'],
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      metadata: json['metadata'],
      links: Links.fromJson(json['_links']),
    );
  }
}

class Event {
  final String type;
  final dynamic resource;
  final dynamic errors;

  Event({required this.type, this.resource, this.errors});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      type: json['type'],
      resource: json['resource'],
      errors: json['errors'],
    );
  }
}
