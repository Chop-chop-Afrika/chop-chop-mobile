import 'package:chop_chop_africa/Pages/home%20page/support_direct/support_messages.dart';
import 'package:chop_chop_africa/backend/support_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllTickets extends StatefulWidget {
  const AllTickets({super.key});

  @override
  State<AllTickets> createState() => _AllTicketsState();
}

class _AllTicketsState extends State<AllTickets> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final supportProvider = Provider.of<SupportProvider>(context, listen: false);
      supportProvider.fetchUserTickets(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  bool _canNavigateToMessages(String? status) {
    if (status == null) return false;
    return status.toLowerCase() == 'open';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Tickets',
          style: TextStyle(
            fontSize: 4.5.pW,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.pW, vertical: 2.pH),
          child: Column(
            children: [
              Expanded(
                child: Consumer<SupportProvider>(
                  builder: (context, supportProvider, child) {
                    final tickets = supportProvider.userTicketsList;

                    if (tickets.isEmpty) {
                      return Center(
                        child: Text(
                          'No tickets found',
                          style: TextStyle(
                            fontSize: 4.pW,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 0.3),
                            borderRadius: BorderRadius.circular(2.pW),
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Colors.grey.shade300, width: 0.3),
                              verticalInside: BorderSide(color: Colors.grey.shade300, width: 0.3),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'ID',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'File attached',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 3.5.pW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            rows: tickets.map((ticket) {
                              final canNavigate = _canNavigateToMessages(ticket.status);
                              return DataRow(
                                cells: [
                                  DataCell(
                                    GestureDetector(
                                      onTap: canNavigate
                                          ? () {
                                              if (ticket.id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SupportMessages(ticketId: ticket.id!),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        ticket.ticketId ?? 'N/A',
                                        style: TextStyle(fontSize: 3.2.pW),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: canNavigate
                                          ? () {
                                              if (ticket.id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SupportMessages(ticketId: ticket.id!),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        ticket.category != null
                                            ? ticket.category!.substring(0, 1).toUpperCase() +
                                                ticket.category!.substring(1)
                                            : 'N/A',
                                        style: TextStyle(fontSize: 3.2.pW),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: canNavigate
                                          ? () {
                                              if (ticket.id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SupportMessages(ticketId: ticket.id!),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 2.pW, vertical: 1.pW),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(ticket.status).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(1.pW),
                                        ),
                                        child: Text(
                                          ticket.status != null
                                              ? ticket.status!.replaceAll('_', ' ').substring(0, 1).toUpperCase() +
                                                  ticket.status!.replaceAll('_', ' ').substring(1)
                                              : 'N/A',
                                          style: TextStyle(
                                            fontSize: 3.pW,
                                            color: _getStatusColor(ticket.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: canNavigate
                                          ? () {
                                              if (ticket.id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SupportMessages(ticketId: ticket.id!),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        ticket.attachment != null && ticket.attachment!.isNotEmpty
                                            ? 'Img-${ticket.attachment!.substring(0, ticket.attachment!.length > 10 ? 10 : ticket.attachment!.length)}...'
                                            : 'No file',
                                        style: TextStyle(fontSize: 3.2.pW),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    GestureDetector(
                                      onTap: canNavigate
                                          ? () {
                                              if (ticket.id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SupportMessages(ticketId: ticket.id!),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        _formatDate(ticket.updatedAt),
                                        style: TextStyle(fontSize: 3.2.pW),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Icon(
                                      Icons.more_horiz,
                                      size: 5.pW,
                                      color: canNavigate ? Colors.black87 : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Consumer<SupportProvider>(
                builder: (context, supportProvider, child) {
                  if (supportProvider.isLoadingMoreTickets) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.pH),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: IAColors.primary,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
