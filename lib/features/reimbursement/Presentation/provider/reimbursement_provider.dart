import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/reimbursement_state.dart';
import 'package:oceanic/features/reimbursement/Presentation/viewModel/reimbursement_viewmodel.dart';

final reimbursementViewModelProvider =
    NotifierProvider<ReimbursementViewModel, ReimbursementState>(
      ReimbursementViewModel.new,
    );
