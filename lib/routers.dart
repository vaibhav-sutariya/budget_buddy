import 'package:flutter/material.dart';
import 'package:frontend/models/creditor.dart';
import 'package:frontend/models/debtor.dart';
import 'package:frontend/models/goal.dart';
import 'package:frontend/models/group.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/screens/categories_screen.dart';
import 'package:frontend/screens/creditors/add_creditor_screen.dart';
import 'package:frontend/screens/creditors/creditors_screen.dart';
import 'package:frontend/screens/creditors/edit_update_creditor_screen.dart';
import 'package:frontend/screens/debtors/add_debtor_screen.dart';
import 'package:frontend/screens/debtors/debtors_screen.dart';
import 'package:frontend/screens/debtors/update_delete_debtor_screen.dart';
import 'package:frontend/screens/goals/add_goal_screen.dart';
import 'package:frontend/screens/goals/edit_goal_screen.dart';
import 'package:frontend/screens/goals/goal_detail_screen.dart';
import 'package:frontend/screens/goals/goals_screen.dart';
import 'package:frontend/screens/goals/reached_goal_detail_screen.dart';
import 'package:frontend/screens/groups/add_expense_screen.dart';
import 'package:frontend/screens/groups/create_group_screen.dart';
import 'package:frontend/screens/groups/groupExpense_detail_screen.dart';
import 'package:frontend/screens/groups/group_detail_screen.dart';
import 'package:frontend/screens/groups/groups_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login/mobile_number_screen.dart';
import 'package:frontend/screens/login/otp_screen.dart';
import 'package:frontend/screens/login/splash_screen.dart';
import 'package:frontend/screens/profile/create_profile_screen.dart';
import 'package:frontend/screens/profile/edit_profile_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/transactions/new_transaction_screen.dart';
import 'package:frontend/screens/transactions/transaction_detail_screen.dart';
import 'package:frontend/screens/transactions/update_transaction_screen.dart';
import 'package:frontend/services/chart_service.dart';
import 'package:frontend/services/transaction_filtering_service.dart';
import 'package:page_transition/page_transition.dart';

import 'models/user.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case MobileNumberScreen.routeName:
      return PageTransition(
        child: const MobileNumberScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case OtpScreen.routeName:
      return PageTransition(
        child: const OtpScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case SplashScreen.routeName:
      return PageTransition(
        child: const SplashScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case GroupsScreen.routeName:
      return PageTransition(
        child: const GroupsScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case GroupDetailScreen.routeName:
      Group data = routeSettings.arguments as Group;
      return PageTransition(
        child: GroupDetailScreen(group: data),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case AddExpenseScreen.routeName:
      List<dynamic> args = routeSettings.arguments as List<dynamic>;
      return PageTransition(
        child: AddExpenseScreen(g: args[0], callback: args[1]),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case CreateGroupScreen.routeName:
      List<User> contacts = routeSettings.arguments as List<User>;
      return PageTransition(
        child: CreateGroupScreen(contacts: contacts),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case GroupExpenseDetailScreen.routeName:
      DetailScreenArgument da = routeSettings.arguments as DetailScreenArgument;
      return PageTransition(
        child: GroupExpenseDetailScreen(
          ge: da.ge,
          members: da.members,
          amount: da.amount,
        ),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case HomeScreen.routeName:
      return PageTransition(
        child: const HomeScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case MyChartScreen.routeName:
      MyChartData data = routeSettings.arguments as MyChartData;
      return PageTransition(
        child: MyChartScreen(chartData: data),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case CreateProfileScreen.routeName:
      return PageTransition(
        child: const CreateProfileScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case NewTransactionScreen.routeName:
      return PageTransition(
        child: const NewTransactionScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case UpdateTransactionScreen.routeName:
      Transaction transaction = routeSettings.arguments as Transaction;
      return PageTransition(
        child: UpdateTransactionScreen(t: transaction),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case TransactionDetailScreen.routeName:
      List<dynamic> args = routeSettings.arguments as List<dynamic>;
      return PageTransition(
        child: TransactionDetailScreen(t: args[0], isFromFilterScreen: args[1]),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case TransactionFilteringScreen.routeName:
      List<Transaction> transactions =
          routeSettings.arguments as List<Transaction>;
      return PageTransition(
        child: TransactionFilteringScreen(transactions: transactions),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case ProfilePage.routeName:
      return PageTransition(
        child: const ProfilePage(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case EditProfileScreen.routeName:
      User user = routeSettings.arguments as User;
      return PageTransition(
        child: EditProfileScreen(user: user),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case CategoriesScreen.routeName:
      return PageTransition(
        child: const CategoriesScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case GoalsScreen.routeName:
      return PageTransition(
        child: const GoalsScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case AddGoalScreen.routeName:
      return PageTransition(
        child: const AddGoalScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case GoalDetailScreen.routeName:
      String id = routeSettings.arguments as String;
      return PageTransition(
        child: GoalDetailScreen(goalID: id),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case EditGoalScreen.routeName:
      Goal goal = routeSettings.arguments as Goal;
      return PageTransition(
        child: EditGoalScreen(goal: goal),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case ReachedGoalDetailScreen.routeName:
      Goal goal = routeSettings.arguments as Goal;
      return PageTransition(
        child: ReachedGoalDetailScreen(goal: goal),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case DebtorsScreen.routeName:
      return PageTransition(
        child: const DebtorsScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case AddDebtorScreen.routeName:
      return PageTransition(
        child: const AddDebtorScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case UpdateDeleteDebtorScreen.routeName:
      Debtor debtor = routeSettings.arguments as Debtor;
      return PageTransition(
        child: UpdateDeleteDebtorScreen(debtor: debtor),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case CreditorsScreen.routeName:
      return PageTransition(
        child: const CreditorsScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case AddCreditorScreen.routeName:
      return PageTransition(
        child: const AddCreditorScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case UpdateDeleteCreditorScreen.routeName:
      Creditor creditor = routeSettings.arguments as Creditor;
      return PageTransition(
        child: UpdateDeleteCreditorScreen(creditor: creditor),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    case SettingScreen.routeName:
      return PageTransition(
        child: const SettingScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(microseconds: 100),
      );

    default:
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: const Text("Oops..404 Not found")),
              body: Center(
                child: Text('No route defined for ${routeSettings.name}'),
              ),
            ),
      );
  }
}
