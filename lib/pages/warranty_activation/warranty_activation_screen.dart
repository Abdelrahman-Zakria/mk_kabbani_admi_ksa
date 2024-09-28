import 'package:mk_kabbani_admin/controllers/pages_controller/warranty_activation_controller.dart';

import '../../config.dart';

class WarrantyActivationScreen extends StatelessWidget {

  WarrantyActivationController warrantyController = Get.put(WarrantyActivationController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Warranty list',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 8.0),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Invoice Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                warrantyController.filterWarrantiesByInvoiceNumber(query);
              },
            ),
          ),

      GetBuilder<WarrantyActivationController>(
        builder: (controller) {
          return Container(
            width: size.width,
            height: size.height / 1.5,
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: controller.filteredWarranties.length,
              itemBuilder: (context, index) {
                var warranty = controller.filteredWarranties[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow("First name", warranty.firstName),
                        _buildInfoRow("Last name", warranty.lastName),
                        _buildInfoRow("Invoice number", warranty.invoiceNumber),
                        _buildInfoRow("Phone", warranty.phone),
                        _buildInfoRow("Emirate", warranty.emirate),
                        _buildInfoRow(
                          "Date",
                          "${warranty.date!.toDate().day}/${warranty.date!.toDate().month}/${warranty.date!.toDate().year}",
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              "Status: ${warranty.status!}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: warranty.status! == "pending" ? Colors.red : Colors.green,
                              ),
                            ),
                            Spacer(),
                            if (warranty.status == "pending")
                              ElevatedButton(
                                onPressed: () {
                                  controller.activateWarrantyByInvoiceNumber(warranty.invoiceNumber!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                ),
                                child: Text(
                                  "Activate",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? "",
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
