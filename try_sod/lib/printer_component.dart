import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:try_sod/printer_provider.dart';

class printer_component extends StatefulWidget {
  const printer_component({super.key});

  @override
  State<printer_component> createState() => _printer_componentState();
}

class _printer_componentState extends State<printer_component> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrinterProvider>(context, listen: true);

    return Container(
      color: Colors.black,
      child: Container(
        margin: EdgeInsets.all(10),
        color: Colors.white,
        height: 300,
        width: 300,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "เจอเครื่องพิมพ์ ${provider.getAllDeviceNames().length} เครื่อง",
                  style: GoogleFonts.abel(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      color: Colors.black),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: ListView.builder(
                  itemCount: provider.getAllDeviceNames().length,
                  itemBuilder: (context, index) {
                    final deviceName = provider.getAllDeviceNames()[index];
                    final isSelected =
                        deviceName == provider.selectedDeviceName;
                    return InkWell(
                      onTap: () {
                        if (!provider.isDeviceConnected) {
                          provider.updateSelectedDeviceName(deviceName);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.grey[900],
                        ),
                        height: 40,
                        margin: EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Text(
                              "   ${index + 1}   ",
                              style: GoogleFonts.abel(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      isSelected ? Colors.black : Colors.white),
                            ),
                            Text(
                              deviceName,
                              style: GoogleFonts.abel(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      isSelected ? Colors.black : Colors.white),
                            ),
                            Expanded(child: Container())
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.scanDevices();
                        },
                        child: Container(
                          margin: EdgeInsets.all(2),
                          color: Colors.blueAccent,
                          child: Center(
                            child: Text(
                              "ค้นหาเครื่องพิมพ์ ",
                              style: GoogleFonts.abel(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          provider.isDeviceConnected
                              ? provider.disconnectDevice()
                              : provider.connectToSelectedDevice(context);
                        },
                        child: Container(
                          margin: EdgeInsets.all(2),
                          color: provider.isDeviceConnected
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          child: Center(
                            child: Text(
                              provider.isDeviceConnected
                                  ? "ตัดการเชื่อมต่อ"
                                  : "เชื่อมต่อ",
                              style: GoogleFonts.abel(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color: provider.isDeviceConnected
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
