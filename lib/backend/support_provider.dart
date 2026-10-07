import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'models/get_ticket_details_model.dart';
import 'models/get_user_tickets_model.dart';
import 'models/register_error.dart';
import 'models/submit_initial_message_model.dart';
import 'models/support_info_model.dart';

class SupportProvider with ChangeNotifier{
  String? supportImage;
  SupportInfoModel? supportInfo;
  GetTicketDetailsModel? ticketDetails;
  GetUserTicketsModel? allUserTickets;
  List<Record> userTicketsList = [];

  /// Closed tickets, from /support/tickets/history. Kept apart from
  /// [userTicketsList], which holds the active ones.
  List<Record> ticketHistoryList = [];
  bool isLoadingHistory = false;
  bool historyLoadedOnce = false;
  bool hasNextHistoryPage = false;
  int currentHistoryPage = 1;

  // Pagination properties
  bool isLoadingMoreTickets = false;
  bool hasNextTicketsPage = false;
  int currentTicketsPage = 1;

  getSupportImage(String image){
    supportImage = image;
    notifyListeners();
  }

  Future<String?> createSupportTicket(
      String category,
      String subject,
      String message,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;

    try {
      String url = "${Env.BACKEND_URL}/support/tickets";

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['accept'] = '*/*';
      request.headers['Authorization'] = "Bearer ${prefs.getString('accessToken')}";

      // Add form fields
      request.fields['category'] = category.toLowerCase();
      request.fields['subject'] = subject;
      request.fields['message'] = message;

      // Add image attachment if available
      if (supportImage != null && supportImage!.isNotEmpty) {
        final extension = path.extension(supportImage!).toLowerCase();

        final mediaType = extension == '.png'
            ? http.MediaType('image', 'png')
            : http.MediaType('image', 'jpeg');
        File imageFile = File(supportImage!);
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      } else {
        request.fields['attachment'] = '';
      }

      print('Sending support ticket request...');

      final streamedResponse = await apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final responseData = SubmitInitialMessageModel.fromJson(jsonResponse);
        // Clear the support image after successful submission
        supportImage = null;
        notifyListeners();
        // Return the ticketId
        return responseData.data?.id;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        final errorResponse = RegisterErrorModel.fromJson(jsonResponse);
        print('Error: ${errorResponse.message}');
        showAlert('Error', errorResponse.message!.join("\n"), 'OK');
        notifyListeners();
        return null;
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      if (errorMessage.contains('Failed host lookup')) {
        showAlert('Error', "Connection is down currently", 'OK');
      } else if (errorMessage.contains('DOCTYPE HTML') || errorMessage.contains('oken') || errorMessage.contains('Connection reset by peer')) {
        showAlert('Error', "Something went wrong", 'OK');
      } else {
        showAlert('Error', errorMessage, 'OK');
      }
      notifyListeners();
      return null;
    }
  }

  Future<void> getSupportInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/support/info";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = SupportInfoModel.fromJson(jsonResponse);
        supportInfo = details;
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }
  }

  Future<void> getTicketDetails(String ticketId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/support/tickets/$ticketId";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = GetTicketDetailsModel.fromJson(jsonResponse);
        ticketDetails = details;
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }
  }

  Future<void> sendMessage(String ticketId, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = "${Env.BACKEND_URL}/support/tickets/$ticketId/messages";

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['accept'] = '*/*';
      request.headers['Authorization'] = "Bearer ${prefs.getString('accessToken')}";

      // Add message field
      request.fields['message'] = message;

      // Add image attachment if available
      if (supportImage != null && supportImage!.isNotEmpty) {
        final extension = path.extension(supportImage!).toLowerCase();

        final mediaType = extension == '.png'
            ? http.MediaType('image', 'png')
            : http.MediaType('image', 'jpeg');
        File imageFile = File(supportImage!);
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      print('Sending message...');

      final streamedResponse = await apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear the support image after successful submission
        supportImage = null;
        // Refresh ticket details to show new message
        await getTicketDetails(ticketId);
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
    }
  }

  /// Past (closed) tickets. The record shape is lighter than the active list —
  /// no messages — so it reuses the same model but only the common fields are
  /// populated.
  Future<void> fetchTicketHistory({bool loadMore = false}) async {
    if (isLoadingHistory) return;
    if (loadMore && !hasNextHistoryPage) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!loadMore) currentHistoryPage = 1;

    isLoadingHistory = true;
    notifyListeners();
    try {
      String url =
          "${Env.BACKEND_URL}/support/tickets/history?page=$currentHistoryPage&pageSize=10";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = GetUserTicketsModel.fromJson(jsonDecode(response.body));
        final fetched = parsed.data?.record ?? [];
        if (loadMore) {
          ticketHistoryList.addAll(fetched);
        } else {
          ticketHistoryList = fetched;
        }
        hasNextHistoryPage = parsed.data?.hasNextPage ?? false;
        if (hasNextHistoryPage) currentHistoryPage++;
      } else if (response.statusCode != 401) {
        print('Ticket history failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Ticket history error: $error');
    } finally {
      historyLoadedOnce = true;
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Closes a ticket the customer no longer needs help with.
  Future<bool> closeTicket(String ticketId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = "${Env.BACKEND_URL}/support/tickets/$ticketId/close";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // /support/tickets includes closed tickets, so refetch both lists
        // rather than guessing what moved where.
        await fetchUserTickets();
        await fetchTicketHistory();
        return true;
      }
      print('Close ticket failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Close ticket error: $error');
      return false;
    }
  }

  /// Sets a ticket's status. [status] must be one of the API's enum values:
  /// open, in_progress, resolved, closed.
  Future<bool> updateTicketStatus(String ticketId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = "${Env.BACKEND_URL}/support/tickets/$ticketId/status";
      final response = await apiClient.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUserTickets();
        return true;
      }
      print('Update ticket status failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Update ticket status error: $error');
      return false;
    }
  }

  /// The statuses a customer can set themselves.
  static const List<String> settableStatuses = ['open', 'resolved', 'closed'];

  Future<void> fetchUserTickets({bool loadMore = false}) async {
    if (loadMore && (isLoadingMoreTickets || !hasNextTicketsPage)) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      if (loadMore) {
        isLoadingMoreTickets = true;
        notifyListeners();
      } else {
        // A fresh load starts from page 1. Without this the list kept the old
        // rows and appended page 1 on top of them, so every revisit to the
        // tickets screen duplicated every ticket.
        currentTicketsPage = 1;
      }

      String url = "${Env.BACKEND_URL}/support/tickets?page=$currentTicketsPage&pageSize=10";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final tickets = GetUserTicketsModel.fromJson(jsonResponse);
        allUserTickets = tickets;
        hasNextTicketsPage = tickets.data?.hasNextPage ?? false;
        currentTicketsPage = tickets.data?.nextPage ?? currentTicketsPage;
        final fetched = tickets.data?.record ?? [];
        if (loadMore) {
          userTicketsList.addAll(fetched);
        } else {
          userTicketsList = fetched;
        }
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      if (loadMore) {
        isLoadingMoreTickets = false;
      }
      notifyListeners();
    }
  }

  void clearData() {
    supportImage = null;
    supportInfo = null;
    ticketDetails = null;
    allUserTickets = null;
    userTicketsList = [];
    isLoadingMoreTickets = false;
    hasNextTicketsPage = false;
    currentTicketsPage = 1;
    notifyListeners();
  }

  showAlert(String title, String content, String defaultAction, {Function(bool)? onDismissed}) {
    UiUtils.showAlertDialog(
        context: globalNavigatorKey.currentContext!,
        title: title,
        content: content,
        defaultActionText: defaultAction,
        onDismissed: (value) {
          if (onDismissed != null) onDismissed(value);
        });
  }
}