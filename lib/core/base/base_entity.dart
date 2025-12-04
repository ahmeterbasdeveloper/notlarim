abstract class BaseEntity {
  final int? id;

  const BaseEntity({this.id});

  // Her model bu metodu içermek zorunda olacak
  Map<String, dynamic> toMap();
}
