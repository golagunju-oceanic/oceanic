import '../../domain/entities/doctor_patient.dart';
import 'doctor_appointment_summary_model.dart';
import 'doctor_json.dart';

class DoctorPatientModel {
  final Map<String, dynamic> json;
  const DoctorPatientModel._(this.json);

  factory DoctorPatientModel.fromJson(Map<String, dynamic> json) =>
      DoctorPatientModel._(json);

  DoctorPatient toEntity() {
    final latest = json['latestAppointment'];
    final patientAppointments = json['appointments'];
    return DoctorPatient(
      id: requireDoctorString(json, 'id'),
      memberId: doctorString(json, 'member_id'),
      firstName: doctorStringOrEmpty(json, 'first_name'),
      middleName: doctorString(json, 'middle_name'),
      lastName: doctorStringOrEmpty(json, 'last_name'),
      maidenName: doctorString(json, 'maiden_name'),
      gender: doctorString(json, 'gender'),
      dateOfBirth: doctorDate(json, 'dob'),
      maritalStatus: doctorString(json, 'marital_status'),
      email: doctorString(json, 'email'),
      phone: doctorString(json, 'phone'),
      photo: doctorString(json, 'photo'),
      bloodGroup: doctorString(json, 'blood_group'),
      genotype: doctorString(json, 'genotype'),
      preExistingCondition: doctorString(json, 'pre_existing_condition'),
      address: doctorString(json, 'address'),
      city: doctorString(json, 'city'),
      stateOfResidence: doctorString(json, 'state_of_residence'),
      height: doctorString(json, 'height'),
      weight: doctorString(json, 'weight'),
      latestAppointment: latest == null
          ? null
          : DoctorAppointmentSummaryModel.fromJson(
              doctorJsonMap(latest, context: 'latestAppointment'),
            ).toEntity(),
      appointments: patientAppointments == null
          ? const []
          : doctorJsonList(patientAppointments, context: 'patient appointments')
              .map((item) => DoctorAppointmentSummaryModel.fromJson(item).toEntity())
              .toList(),
    );
  }
}
