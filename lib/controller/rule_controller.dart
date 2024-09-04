import '../repository/rule_repository.dart';

class RuleController {
  final RuleRepository _ruleRepository;

  RuleController(this._ruleRepository);

  Future<int> getCustomerMaxDebt() => _ruleRepository.getCustomerMaxDebt();

  Future<int> getMinStockPostOrder() => _ruleRepository.getMinStockPostOrder();

  Future<int> getMaxStockPreReceipt() => _ruleRepository.getMaxStockPreReceipt();

  Future<int> getMinReceive() => _ruleRepository.getMinReceive();

  Future<bool> getNegativeDebtRights() => _ruleRepository.getNegativeDebtRights();

  Future<void> updateCustomerMaxDebt(int customerMaxDebt) => _ruleRepository.updateCustomerMaxDebt(customerMaxDebt);

  Future<void> updateMinStockPostOrder(int minStockPostOrder) => _ruleRepository.updateMinStockPostOrder(minStockPostOrder);

  Future<void> updateMaxStockPreReceipt(int maxStockPreReceipt) => _ruleRepository.updateMaxStockPreReceipt(maxStockPreReceipt);

  Future<void> updateMinReceive(int minReceive) => _ruleRepository.updateMinReceive(minReceive);

  Future<void> updateNegativeDebtRights(bool negativeDebtRights) => _ruleRepository.updateNegativeDebtRights(negativeDebtRights);
}