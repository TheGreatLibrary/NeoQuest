import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neoflex_quiz/database/models/account.dart';
import 'package:neoflex_quiz/database/models/achievement.dart';
import 'package:neoflex_quiz/database/models/product.dart';
import 'package:neoflex_quiz/database/models/quiz_cards.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/cart_item.dart';
import 'models/order_items_with_product.dart';
import 'models/orders.dart';
import 'models/question.dart';
import 'models/story.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'neoflex.db');

    bool exists = await databaseExists(path);
    if (!exists) {
      ByteData data = await rootBundle.load('assets/database/neoflex.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, version: 1);
  }




  /// quiz_cards

  Future<List<QuizCards>> getCards() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('quiz_cards');

    return result.map((row) => QuizCards.fromMap(row)).toList();
  }

  Future<void> updateCardState(int id, int newState) async {
    final db = await database;
    await db.update(
      'quiz_cards',
      {'state': newState},
      where: "quiz_id = ?",
      whereArgs: [id],
    );
  }

  Future<int?> getCardState(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'quiz_cards',
      columns: ['state'],
      where: 'quiz_id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['state'] as int;
    }

    return null;
  }

  Future<int> rewardPlayer({required int quizId, int? correctAnswers}) async {
    final db = await database;
    final List<Map<String, dynamic>> quizData = await db.query(
      'quiz_cards',
      columns: ['sum_price'],
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );

    if (quizData.isEmpty) return 0;

    int remainingMoney = quizData.first['sum_price'] as int;
    int actualReward = 0;

    if (correctAnswers == null) {
      actualReward = remainingMoney;
    } else if (correctAnswers == 4) {
      actualReward = (remainingMoney >= correctAnswers * 50) ? correctAnswers * 50 : remainingMoney;
    } else if (correctAnswers == 3) {
      if (remainingMoney >= 200) {
        actualReward = (remainingMoney >= correctAnswers * 50) ? correctAnswers * 50 : remainingMoney;
      }
    }

    if (actualReward <= 0) return 0;

    await addMoney(actualReward);

    await db.update(
      'quiz_cards',
      {'sum_price': remainingMoney - actualReward},
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );

    return actualReward;
  }

  /// story

  Future<List<Story>> getStoryDialogs(int quizId) async {
    final db = await database;
    final result = await db.query(
      'story',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );

    return result.map((row) => Story.fromMap(row)).toList();
  }

  Future<int> addStoryDialog(Story story) async {
    final db = await database;

    return await db.insert(
      'story',
      story.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// questions

  Future<List<Question>> getQuestions(int quizId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'questions',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'RANDOM()'
    );

    return result.map((row) => Question.fromMap(row)).toList();
  }

  Future<int> addQuestion(Question question) async {
    final db = await database;
    return await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// product

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('product');

    return result.map((row) => Product.fromMap(row)).toList();
  }

  Future<Product?> getProductById(int productId) async {
    final db = await database;
    final result = await db.query(
      'product',
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    return result.isNotEmpty ? Product.fromMap(result.first) : null;
  }


  /// cart

  Future<void> removeFromCart(int cartId) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> removeProductFromCart(int productId) async {
    final db = await database;
    await db.delete('cart', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<void> updateCartItemQuantity(int cartId, int quantity) async {
    final db = await database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<bool> isCartEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cart'));
    return count == 0;
  }

  Future<int> addToCart(int productId, int quantity) async {
    final db = await database;

    final existingItem = await db.query(
      'cart',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (existingItem.isNotEmpty) {
      if (existingItem.first['quantity'] as int < 99 || quantity == -1) {
        int newQuantity = (existingItem.first['quantity'] as int) + quantity;
        return await db.update(
          'cart',
          {'quantity': newQuantity},
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }
    }
    else {
      return await db.insert(
        'cart',
        {
          'product_id': productId,
          'quantity': quantity,
        },
      );
    }
    return -1;
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT cart.id AS cart_id, 
           product.id AS product_id, 
           product.title, 
           product.image,
           product.price, 
           cart.quantity 
    FROM cart 
    JOIN product ON cart.product_id = product.id
  ''');
    return result.map((row) => CartItem.fromMap(row)).toList();
  }


  /// orders

  Future<int> createOrder(String createdAt, String deliveryDate, String cancellationDate, int totalPrice) async {
    final db = await database;
    return await db.transaction((txn) async {
      final currentMoneyResult = await txn.rawQuery('SELECT money FROM account LIMIT 1');
      int currentMoney = currentMoneyResult.isNotEmpty ? currentMoneyResult.first['money'] as int? ?? 0 : 0;

      if (currentMoney < totalPrice) {
        throw Exception('Недостаточно средств');
      }

      await txn.rawUpdate('UPDATE account SET money = ? WHERE id = 1', [currentMoney - totalPrice]);

      final maxOrder = await txn.rawQuery('SELECT COALESCE(MAX(order_number), 0) + 1 AS new_order FROM orders');
      int newOrderNumber = maxOrder.first['new_order'] as int? ?? 1; // создаем номер заказа

      int orderId = await txn.rawInsert('''
        INSERT INTO orders (order_number, created_at, delivery_date, cancellation_date, status, tracking_number, amount) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        newOrderNumber,
        createdAt,
        deliveryDate,
        cancellationDate,
        'Доставляется',
        'TRK${DateTime.now().millisecondsSinceEpoch}',
        totalPrice
      ]); // создается заказ

      await txn.rawInsert('''
        INSERT INTO order_items (order_id, product_id, quantity) 
        SELECT ?, product_id, quantity FROM cart
      ''', [orderId]); // переношу товары в новую таблицу

      await txn.rawDelete('DELETE FROM cart'); // очищаю корзину

      return orderId;
    });
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final result = await db.query('orders');
    return result.map((row) => Order.fromMap(row)).toList();
  }

  Future<void> updateOrdersStatus() async {
    final db = await database;
    final orders = await db.query('orders', where: "status IN (?, ?)", whereArgs: ['Доставляется', 'Доставлен']);
    final now = DateTime.now();

    for (var order in orders) {
      String status = order['status'] as String;

      if (status == 'Доставляется') {
        await updateStatus('Доставлен', DateFormat('dd.MM.yyyy HH:mm:ss').parse(order['delivery_date'] as String), now, order['id'] as int, order);
        await updateStatus('Срок истек', DateFormat('dd.MM.yyyy HH:mm:ss').parse(order['cancellation_date'] as String), now, order['id'] as int, order);
      }
      else if (status == 'Доставлен') {
        await updateStatus('Срок истек', DateFormat('dd.MM.yyyy HH:mm:ss').parse(order['cancellation_date'] as String), now, order['id'] as int, order);
      }
    }
  }

  Future<void> updateStatus(String newStatus, DateTime date, DateTime nowDate, int orderId, Map<String, dynamic> order) async {
    final db = await database;
    if (nowDate.isAfter(date)) {
      final currentOrder = await db.query('orders', columns: ['status'], where: 'id = ?', whereArgs: [orderId]);

      if (currentOrder.isNotEmpty && currentOrder.first['status'] != newStatus) {
        await db.update('orders', {'status': newStatus}, where: 'id = ?', whereArgs: [orderId]);

        if (newStatus == 'Срок истек') {
          await refundMoney(order);
        }
      }
    }
  }

  Future<void> refundMoney(Map<String, dynamic> order) async {
    int orderAmount = order['amount'] as int;
    int deliveryFee = 10;
    int refundAmount = ((orderAmount - deliveryFee) * 0.9).round();
    await addMoney(refundAmount);
  }

  Future<List<OrderItemWithProduct>> getOrderItemsWithProduct(int orderId) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      order_items.product_id, 
      order_items.quantity, 
      product.title, 
      product.price, 
      product.image 
    FROM order_items
    JOIN product ON order_items.product_id = product.id
    WHERE order_items.order_id = ?
  ''', [orderId]);

    return result.map((map) => OrderItemWithProduct.fromMap(map)).toList();
  }


  /// account

  Future<int> getMoney() async {
    final db = await database;
    final maps = await db.query(
      'account',
      columns: ['money'],
      limit: 1,
    );

    return maps.isNotEmpty ? maps.first['money'] as int : 0;
  }

  Future<void> addMoney(int amount) async {
    final db = await database;
    int currentMoney = await getMoney();
    await db.update('account', {'money': currentMoney + amount}, where: 'id = 1');
  }

  Future<int> insertOrUpdateAccount(Account account) async {
    final db = await database;

    return await db.insert(
      'account',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Account> getAccount() async {
    final db = await database;
    final maps = await db.query('account', limit: 1);

    return Account.fromMap(maps.first);
  }

  Future<void> updateAccount(String fullName, String phone, String postalCode) async {
    final db = await database;
    await db.update(
      'account',
      {'fullname': fullName, 'phone': phone, 'postal_code': postalCode},
      where: 'id = 1',
    );
  }

  Future<void> updateNickNameAccount(String nickname) async {
    final db = await database;
    await db.update(
      'account',
      {'nickname': nickname},
      where: 'id = 1',
    );
  }

  Future<bool> isUserRegistered() async {
    final db = await database;
    final result = await db.query('account', limit: 1);
    return result.isNotEmpty;
  }


  /// achievement

  Future<List<Achievement>> getAchievements() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('achievement');

    return result.map((row) => Achievement.fromMap(row)).toList();
  }

  Future<void> updateAchieveStatus(int id, int newStatus) async {
    final db = await database;
    await db.update(
      'achievement',
      {'status': newStatus},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> getAchieveStatus(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'achievement',
      columns: ['status'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['status'] as int;
    }

    return -1;
  }
}
