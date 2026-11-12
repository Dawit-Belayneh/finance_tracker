import '../models/transaction.dart';

/// Replaces [target] with [updated] in [list], matching by identity first.
bool replaceTransactionInList(
  List<Transaction> list,
  Transaction target,
  Transaction updated,
) {
  var index = list.indexWhere((t) => identical(t, target));
  if (index == -1) {
    index = list.indexOf(target);
  }
  if (index == -1) return false;
  list[index] = updated;
  return true;
}

/// Removes [target] from [list], matching by identity first.
bool removeTransactionFromList(
  List<Transaction> list,
  Transaction target,
) {
  var index = list.indexWhere((t) => identical(t, target));
  if (index == -1) {
    index = list.indexOf(target);
  }
  if (index == -1) return false;
  list.removeAt(index);
  return true;
}
