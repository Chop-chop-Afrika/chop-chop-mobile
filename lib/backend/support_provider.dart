import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response body: ${response.body}');

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

  Future<void> fetchUserTickets({bool loadMore = false}) async {
    if (loadMore && (isLoadingMoreTickets || !hasNextTicketsPage)) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      if (loadMore) {
        isLoadingMoreTickets = true;
        notifyListeners();
      }

      String url = "${Env.BACKEND_URL}/support/tickets?page=$currentTicketsPage&pageSize=10";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final tickets = GetUserTicketsModel.fromJson(jsonResponse);
        allUserTickets = tickets;
        hasNextTicketsPage = tickets.data?.hasNextPage ?? false;
        currentTicketsPage = tickets.data?.nextPage ?? currentTicketsPage;
        userTicketsList.addAll(tickets.data?.record ?? []);
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