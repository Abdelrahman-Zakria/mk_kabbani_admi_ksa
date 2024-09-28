import 'package:cloud_firestore/cloud_firestore.dart';

class WarrantyActivation{
  String? firstName;
  String? lastName;
  String? phone;
  String? emirate;
  Timestamp? date;
  String? invoiceNumber;
  String? status;

  WarrantyActivation({
  this.firstName,this.lastName,this.emirate,this.phone,this.date,this.invoiceNumber,this.status
});
}