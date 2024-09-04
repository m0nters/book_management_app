import '../network/rule_data_source.dart';

class RuleRepository {
  final _dataSource = RuleDataSource();

  Future<int> getCustomerMaxDebt() => _dataSource.readCustomerMaxDebt();

  Future<int> getMinStockPostOrder() => _dataSource.readMinStockPostOrder();

  Future<int> getMaxStockPreReceipt() => _dataSource.readMaxStockPreReceipt();

  Future<int> getMinReceive() => _dataSource.readMinReceive();

  Future<bool> getNegativeDebtRights() => _dataSource.readNegativeDebtRights();

  Future<void> updateCustomerMaxDebt(int customerMaxDebt) => _dataSource.updateCustomerMaxDebt(customerMaxDebt);

  Future<void> updateMinStockPostOrder(int minStockPostOrder) => _dataSource.updateMinStockPostOrder(minStockPostOrder);

  Future<void> updateMaxStockPreReceipt(int maxStockPreReceipt) => _dataSource.updateMaxStockPreReceipt(maxStockPreReceipt);

  Future<void> updateMinReceive(int minReceive) => _dataSource.updateMinReceive(minReceive);

  Future<void> updateNegativeDebtRights(bool negativeDebtRights) => _dataSource.updateNegativeDebtRights(negativeDebtRights);
}